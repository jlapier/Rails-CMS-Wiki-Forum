require 'spec_helper'

describe Blog::PostsController do

  subject{ mock_model(Blog::Post) }
  
  def mock_admin(stubs={})
    stub_model(User, {:is_admin? => true})
  end
  
  def mock_user(stubs={})
    stub_model(User, {:is_admin? => false})
  end
  
  before(:each) do
    controller.stub(:require_user){ mock_user }
    controller.stub(:current_user){ mock_user }
  end

  describe "GET 'public'" do
    before(:each) do
      Blog::Post.stub_chain(:published, :order){ [subject] }
    end
    it "loads published @posts" do
      get :public
      assigns(:posts).should eq [subject]
    end
    it "renders blog/posts/public" do
      get :public
      response.should render_template("blog/posts/public")
    end
  end

  describe "GET 'index'" do
    it "loads @posts" do
      Blog::Post.stub(:order){ [subject] }
      get :index
      assigns(:posts).should eq [subject]
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

  describe "GET 'show' (:id => int)" do
    before(:each) do
      Blog::Post.stub(:find).with(1){ subject }
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
  
  describe "DELETE 'destroy' (:id => int)" do
    before(:each) do
      subject.stub(:title){ 'deleted' }
      Blog::Post.stub(:destroy){ subject }
    end
    it "destroys the post of :id" do
      Blog::Post.should_receive(:destroy).with(1){ subject }
      delete :destroy, :id => 1
    end
    it "redirects to blog_posts_path" do
      delete :destroy, :id => 1
      response.should redirect_to blog_posts_path
    end
  end
  
  describe "POST 'upload_handler' (:id => int, :upload => file)" do
    let(:upload){fixture_file_upload('spec/fixtures/asset.txt', 'text/plain')}
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

end
