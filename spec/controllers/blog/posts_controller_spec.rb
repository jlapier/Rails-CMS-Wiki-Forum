require 'spec_helper'

describe Blog::PostsController do

  subject{ mock_model(Blog::Post) }
  
  def mock_admin(stubs={})
    @mock_admin ||= stub_model(User, {:is_admin? => true, :logged_in? => true})
  end
  
  def mock_user(stubs={})
    @mock_user ||= stub_model(User, {:is_admin? => false, :logged_in? => true})
  end
  
  before(:each) do
    controller.stub(:require_user){ mock_user }
    controller.stub(:current_user){ mock_user }
    controller.stub(:has_authorization?){ true }
  end

  describe "GET 'index'" do
    before(:each) do
      Blog::Post.stub(:order){ mock('Relation', {
        :[] => subject,
        :published => ['published'],
        :by => ['author']
      }) }
    end
    it "loads all @posts for logged in users" do
      Blog::Post.stub(:order){ [subject] }
      get :index
      assigns(:posts).should eq [subject]
    end
    it "loads published @posts for anonymous users" do
      controller.stub(:current_user){ nil }
      get :index
      assigns(:posts).should eq ['published']
    end
    it "loads @posts.by an author given params[:author_id] is present" do
      get :index, :author_id => 1
      assigns(:posts).should eq ['author']
    end
    it "renders blog/posts/index" do
      get :index
      response.should render_template("blog/posts/index")
    end
  end

  describe "GET 'new'" do
    it "loads a new @post" do
      Blog::Post.stub(:new){ subject }
      get :new
      assigns(:post).should eq subject
    end
    it "renders blog/posts/new" do
      get :new
      response.should render_template("blog/posts/new")
    end
  end
  
  describe "POST 'create' (:blog_post => {})" do
    let(:params) do
      {:title => 'new post', :body => 'rather short, no?'}
    end
    before(:each) do
      subject.stub(:title){ 'new post' }
      subject.stub(:author=)
      subject.stub(:modifying_user=)
      subject.stub(:save)
      Blog::Post.stub(:new){ subject }
    end
    it "loads a new @post from :blog_post" do
      Blog::Post.should_receive(:new).with(params.stringify_keys){ subject }
      post :create, :blog_post => params
      assigns(:post).should eq subject
    end
    it "sets the @post.author" do
      subject.should_receive(:author=)
      post :create
    end
    it "saves the @post" do
      subject.should_receive(:save)
      post :create
    end
    context "save succeeds :)" do
      before(:each) do
        subject.stub(:save){ true }
      end
      it "redirects to blog_posts_path w/ flash[:notice]" do
        post :create
        response.should redirect_to edit_blog_post_path(subject.id)
        flash[:notice].should_not be_nil
      end
    end
    context "save fails :(" do
      before(:each) do
        subject.stub(:save){ false }
      end
      it "renders blog/posts/new" do
        post :create
        response.should render_template("blog/posts/new")
      end
    end
  end

  describe "GET 'edit' (:id => int)" do
    before(:each) do
      controller.stub(:record_editing_user_for)
      Blog::Post.stub(:find).with(1){ subject }
    end
    it "loads a @post from params[:id]" do
      get :edit, :id => 1
      assigns(:post).should eq subject
    end
    it "records the editing_user" do
      controller.should_receive(:record_editing_user_for).with(subject)
      get :edit, :id => 1
    end
    it "loads @rel_dir and @assets for @post" do
      get :edit, :id => 1
      assigns(:rel_dir).should eq "blog_post_assets/blog_post_#{subject.id}"
      assigns(:assets).should be_kind_of Array
    end
    it "renders blog/posts/edit" do
      get :edit, :id => 1
      response.should render_template("blog/posts/edit")
    end
  end
  
  describe "PUT 'update' (:id => int, :blog_post => {})" do
    let(:params){ {:some => 'attributes'} }
    before(:each) do
      subject.stub(:published)
      subject.stub(:modifying_user=)
      subject.stub(:title){ 'Updating post' }
      subject.stub(:update_attributes).with(params.stringify_keys){ false }
      controller.stub(:remove_editing_user_record_for).with(subject)
      Blog::Post.stub(:find).with(1){ subject }
    end
    it "loads a @post from :id" do
      put :update, :id => 1, :blog_post => params
      assigns(:post).should eq subject
    end
    it "updates the @post from :blog_post" do
      subject.should_receive(:update_attributes).with(params.stringify_keys)
      put :update, :id => 1, :blog_post => params
    end
    context "update succeeds :)" do
      before(:each) do
        subject.stub(:update_attributes){ true }
      end
      it "notifies all admin users of the update IF post is published" do
        subject.stub(:published){ true }
        Notifier.should_receive(:published_blog_post_updated).with(subject, mock_user)
        put :update, :id => 1
      end
      it "removes the editing user record for @post" do
        controller.should_receive(:remove_editing_user_record_for).with(subject)
        put :update, :id => 1, :blog_post => params
      end
      it "redirects to the blog post path w/ a flash[:notice]" do
        put :update, :id => 1, :blog_post => params
        response.should redirect_to blog_post_path(subject)
        flash[:notice].should_not be_nil
      end
    end
    context "update fails :(" do
      it "loads @rel_dir and @assets for @post" do
        put :update, :id => 1, :blog_post => params
        assigns(:rel_dir).should eq "blog_post_assets/blog_post_#{subject.id}"
        assigns(:assets).should be_kind_of Array
      end
      it "renders blog/posts/edit" do
        put :update, :id => 1, :blog_post => params
        response.should render_template("blog/posts/edit")
      end
    end
  end
  
  describe "POST 'publish' (:id => int)" do
    before(:each) do
      subject.stub(:title){ "Post TItle" }
      subject.stub(:toggle_published){ true }
      subject.stub(:published){ false }
      Blog::Post.stub(:find).with(1){ subject }
    end
    it "publishes the post loaded from :id" do
      subject.should_receive(:toggle_published)
      post :publish, :id => 1
    end
    context "publication fails :(" do
      before(:each) do
        subject.stub(:toggle_published){ false }
      end
      it "reflects failure in the message returned to the user" do
        post :publish, :id => 1
        flash[:notice].should include("failed")
      end      
    end
    context "publication succeeds :)" do
      it "redirects to the post path with a flash[:notice]" do
        post :publish, :id => 1
        response.should redirect_to blog_post_path(subject)
        flash[:notice].should_not be_nil
      end
    end
  end

  describe "GET 'show' (:id => int)" do
    before(:each) do
      subject.stub(:published){ false }
      subject.stub(:comments){ mock('Relation', {
        :approved => []
      }) }
      Blog::Post.stub(:find).with(1){ subject }
    end
    context "post is published or user is authenticated" do
      before(:each) do
        subject.stub(:published){ true }
      end
      it "loads @post from :id" do
        get :show, :id => 1
        assigns(:post).should eq subject
      end
      it "renders blog/posts/show" do
        get :show, :id => 1
        response.should render_template("blog/posts/show")
      end
    end
    context "post is NOT published and user is NOT authenticated" do
      before(:each) do
        controller.stub(:require_user){ false }
        controller.stub(:current_user)
      end
      it "redirects to the blog posts path" do
        get :show, :id => 1
        response.should redirect_to blog_posts_path
      end
    end
  end
  
  describe "DELETE 'destroy' (:id => int)" do
    before(:each) do
      subject.stub(:title){ 'deleted' }
      subject.stub(:destroy)
      Blog::Post.stub(:find).with(1){ subject }
    end
    context "user is authorized" do
      before(:each) do
        controller.stub(:has_authorization?){ true }
      end
      it "destroys the post of :id" do
        subject.should_receive(:destroy)
        delete :destroy, :id => 1
      end
      it "redirects to blog_posts_path" do
        delete :destroy, :id => 1
        response.should redirect_to blog_posts_path
      end
    end
    context "user is NOT authorized" do
      before(:each) do
        controller.stub(:has_authorization?){ false }
      end
      it "does NOT destroy any post" do
        subject.should_not_receive :destroy
        delete :destroy, :id => 1
      end
      it "redirects to the blog posts path" do
        delete :destroy, :id => 1
        response.should redirect_to blog_posts_path
      end
    end
  end
  
  describe "POST 'upload_handler' (:id => int, :upload => file)" do
    let(:upload){fixture_file_upload('/asset.txt', 'text/plain')}
    before(:each) do
      Blog::Post.stub(:find).with(1){ subject }
      controller.stub(:save_asset_for).with(subject, upload)
    end
    it "loads a @post from :id" do
      post :upload_handler, :id => 1, :upload => upload
      assigns(:post).should eq subject
    end
    it "saves the uploaded asset" do
       controller.should_receive(:save_asset_for).with(subject, upload)
       post :upload_handler, :id => 1, :upload => upload
    end
    it "renders text content calling some CKEDITOR func" do
      post :upload_handler, :id => 1, :upload => upload
      response.body.should include "parent.CKEDITOR.tools.callFunction"
    end
  end
  
  describe "POST 'delete_asset' (:id => int, :asset => filename)" do
    let(:asset){ 'img.jpg' }
    before(:each) do
      Blog::Post.stub(:find).with(1){ subject }
      controller.stub(:rm_asset_for).with(subject, asset){ true }
    end
    it "loads a @post from :id" do
      post :delete_asset, :id => 1, :asset => asset
      assigns(:post).should eq subject
    end
    it "deletes the given asset" do
      controller.should_receive(:rm_asset_for).with(subject, asset)
      post :delete_asset, :id => 1, :asset => asset
    end
    context "file is found and deleted" do
      it "sets a flash[:notice] and redirects to edit_blog_post_path for @post" do
        post :delete_asset, :id => 1, :asset => asset
        response.should redirect_to edit_blog_post_path(subject)
        flash[:notice].should_not be_nil
      end
    end
    context "asset can not be found" do
      it "sets a flash[:error] and redirects to edit_blog_post_path for @post" do
        controller.stub(:rm_asset_for).with(subject, asset){ false }
        post :delete_asset, :id => 1, :asset => asset
        response.should redirect_to edit_blog_post_path(subject)
        flash[:error].should_not be_nil
      end
    end
  end
  
  describe "POST 'un_edit' (:id => int)" do
    before(:each) do
      subject.stub(:title){ 'Un edited' }
      controller.stub(:remove_editing_user_record_for).with(subject)
      Blog::Post.stub(:find).with(1){ subject }
    end
    it "loads a @post from :id" do
      post :un_edit, :id => 1
      assigns(:post).should eq subject
    end
    context "std http request" do
      it "sets flash[:notice] and redirects to blog_posts_path" do
        post :un_edit, :id => 1
        response.should redirect_to blog_posts_path
        flash[:notice].should_not be_nil
      end
    end
    context "xml http request" do
      it "renders :nothing" do
        xhr :post, :un_edit, :id => 1
        response.body.should eq " "
      end
    end
  end
  
  describe "GET 'revisions' (:id => int)" do
    before(:each) do
      subject.stub(:revisions){ ['revisions'] }
      Blog::Post.stub(:find).with(1){ subject }
    end
    it "loads @post from :id" do
      get :revisions, :id => 1
      assigns(:post).should eq subject
    end
    it "loads @revisions from @post" do
      subject.should_receive(:revisions){ ['revisions'] }
      get :revisions, :id => 1
      assigns(:revisions).should eq ['revisions']
    end
    it "redirects to blog_post_path @post with :notice if no revisions are found" do
      subject.stub(:revisions){ [] }
      get :revisions, :id => 1
      response.should redirect_to blog_post_path subject
      flash[:notice].should_not be_blank
    end
    it "renders the revisions template if revisions are found" do
      get :revisions, :id => 1
      response.should render_template("blog/posts/revisions")
    end
  end
  
  describe "GET 'revision' (:id => int, :revision_number => int)" do
    let(:post_revision){ mock_model(Blog::PostRevision) }
    before(:each) do
      subject.stub(:find_revision).with(2){ post_revision }
      Blog::Post.stub(:find).with(1){ subject }
    end
    it "loads @post from :id" do
      get :revision, :id => 1, :revision_number => 2
      assigns(:post).should eq subject
    end
    it "loads @revision from @post and :revision_number" do
      get :revision, :id => 1, :revision_number => 2
      assigns(:revision).should eq post_revision
    end
    it "renders the revision template" do
      get :revision, :id => 1, :revision_number => 2
      response.should render_template("blog/posts/revision")
    end
  end
  
  describe "PUT 'revert' (:id => int, :to => int)" do
    before(:each) do
      subject.stub(:revert_to!).with(2, :revision_name => "Reverted to revision #2", :modifying_user => mock_user)
      Blog::Post.stub(:find).with(1){ subject }
    end
    it "loads @post from :id" do
      put :revert, :id => 1, :to => 2
      assigns(:post).should eq subject
    end
    it "reverts post to :to" do
      subject.should_receive(:revert_to!).with(2, :revision_name => "Reverted to revision #2", :modifying_user => mock_user)
      put :revert, :id => 1, :to => 2
    end
    it "redirects to blog_post_path with :notice" do
      put :revert, :id => 1, :to => 2
      response.should redirect_to blog_post_path subject
      flash[:notice].should_not be_blank
    end
  end
  
  describe "PUT 'restore' (:revision_id => int)" do
    let(:post_revision){ mock_model(Blog::PostRevision) }
    before(:each) do
      post_revision.stub(:restore)
      Blog::PostRevision.stub(:find).with(1){ post_revision }
    end
    it "loads @revision from :revision_id" do
      put :restore, :revision_id => 1
      assigns(:revision).should eq post_revision
    end
    it "restores the @revision" do
      post_revision.should_receive(:restore)
      put :restore, :revision_id => 1
    end
  end
  
  describe "GET 'deleted'" do
    let(:post_revision) do
      mock('Relation', {
        :[] => []
      })
    end
    before(:each) do
      Blog::PostRevision.stub(:where).with("revisable_deleted_at is not null"){ post_revision }
    end
    it "loads @deleted_posts from PostRevision" do
      get :deleted
      assigns(:deleted_posts).should eq post_revision
    end
    it "renders the deleted template" do
      get :deleted
      response.should render_template("blog/posts/deleted")
    end
  end

end
