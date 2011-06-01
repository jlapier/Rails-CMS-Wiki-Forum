require 'spec_helper'

describe Blog::CommentsController do
  subject{ mock_model(Blog::Comment, {
    :save => true
  }) }
  let(:blog_post) do
    stub_model(Blog::Post)
  end
  
  describe "requiring authorization" do
    before(:each) do
      Blog::Comment.stub(:find).with(1){ subject }
    end
    it "wraps has_authorization?" do
      controller.should_receive(:has_authorization?).with(:approve, subject)
      post :approve, :id => 1
    end
    it "redirects to blog_posts path with :notice when authz FAILS" do
      controller.stub(:has_authorization?){ false }
      post :approve, :id => 1
      response.should redirect_to blog_posts_path
      flash[:notice].should_not be_blank
    end
  end
  
  describe ":approve, :id => int" do
    before(:each) do
      controller.stub(:require_authorization){ true }
      subject.stub(:approve)
      Blog::Comment.stub(:find).with(1){ subject }
    end
    it "requires authorization" do
      controller.should_receive(:require_authorization)
      post :approve, :id => 1
    end
    it "approves the @comment" do
      subject.should_receive(:approve)
      post :approve, :id => 1
    end
    it "saves the @comment" do
      subject.should_receive(:save)
      post :approve, :id => 1
    end
    it "redirects to blog_dashboard_path with a :notice" do
      post :approve, :id => 1
      response.should redirect_to blog_dashboard_path
      flash[:notice].should_not be_blank
    end
  end
  
  describe ":destroy, :id => int" do
    before(:each) do
      controller.stub(:require_authorization){ true }
      subject.stub(:destroy)
      Blog::Comment.stub(:find).with(1){ subject }
    end
    it "destroys the @comment" do
      subject.should_receive(:destroy)
      delete :destroy, :id => 1
    end
    it "redirects to blog_dashboard_path with :notice" do
      delete :destroy, :id => 1
      response.should redirect_to blog_dashboard_path
      flash[:notice].should_not be_blank
    end
  end
  
  describe "'create', (:blog_comment)" do
    let(:params) do
      {
        :post_id => 1,
        :commenter_email => 'email@test.com',
        :commenter_name => 'name',
        :body => 'this is a comment'
      }
    end
    before(:each) do
      subject.stub(:request_approval)
      subject.stub(:post){ blog_post }
      blog_post.stub(:published){ true }
      subject.stub(:post){ blog_post }
      subject.stub(:post_id){ blog_post.id }
      Blog::Comment.stub(:new).with(params.stringify_keys){ subject }
    end
    it "is publicly accessible" do
      controller.should_not_receive :require_authorization
      post :create, :blog_comment => params
    end
    it "loads a new Blog::Comment" do
      Blog::Comment.should_receive(:new).with(params.stringify_keys){ subject }
      post :create, :blog_comment => params
    end
    it "as @comment" do
      post :create, :blog_comment => params
      assigns(:comment).should eq subject
    end
    it "requests approval for @comment" do
      subject.should_receive(:request_approval)
      post :create, :blog_comment => params
    end
    it "saves the @comment" do
      subject.should_receive(:save)
      post :create, :blog_comment => params
    end
    context "save succeeds :)" do
      before(:each) do
        subject.stub(:save){ true }
      end
      it "sets a flash[:notice]" do
        post :create, :blog_comment => params
        flash[:notice].should_not be_blank
      end
      it "redirects to the blog post path" do
        post :create, :blog_comment => params
        response.should redirect_to blog_post_path blog_post.id
      end
    end
    context "save fails :(" do
      before(:each) do
        subject.stub(:save){ false }
      end
      context "and post is not published" do
        before(:each) do
          blog_post.stub(:published){ false }
        end
        it "sets a flash[:notice]" do
          post :create, :blog_comment => params
          flash[:notice].should_not be_blank
        end
        it "redirects to blog_posts_path" do
          post :create, :blog_comment => params
          response.should redirect_to blog_posts_path
        end
      end
      context "and post IS published" do
        before(:each) do
          blog_post.stub(:published){ true }
        end
        it "renders the posts/show template" do
          post :create, :blog_comment => params
          response.should render_template("blog/posts/show")
        end
      end
    end
  end
end
