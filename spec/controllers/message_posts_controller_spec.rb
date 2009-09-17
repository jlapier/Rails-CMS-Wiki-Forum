require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagePostsController do

  def mock_message_post(stubs={})
    @mock_message_post ||= mock_model(MessagePost, stubs)
  end

  describe "GET index" do
    it "assigns all message_posts as @message_posts" do
      MessagePost.stub!(:find).with(:all).and_return([mock_message_post])
      get :index
      assigns[:message_posts].should == [mock_message_post]
    end
  end

  describe "GET show" do
    it "assigns the requested message_post as @message_post" do
      MessagePost.stub!(:find).with("37").and_return(mock_message_post)
      get :show, :id => "37"
      assigns[:message_post].should equal(mock_message_post)
    end
  end

  describe "GET new" do
    it "assigns a new message_post as @message_post" do
      MessagePost.stub!(:new).and_return(mock_message_post)
      get :new
      assigns[:message_post].should equal(mock_message_post)
    end
  end

  describe "GET edit" do
    it "assigns the requested message_post as @message_post" do
      MessagePost.stub!(:find).with("37").and_return(mock_message_post)
      get :edit, :id => "37"
      assigns[:message_post].should equal(mock_message_post)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created message_post as @message_post" do
        MessagePost.stub!(:new).with({'these' => 'params'}).and_return(mock_message_post(:save => true))
        post :create, :message_post => {:these => 'params'}
        assigns[:message_post].should equal(mock_message_post)
      end

      it "redirects to the created message_post" do
        MessagePost.stub!(:new).and_return(mock_message_post(:save => true))
        post :create, :message_post => {}
        response.should redirect_to(message_post_url(mock_message_post))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved message_post as @message_post" do
        MessagePost.stub!(:new).with({'these' => 'params'}).and_return(mock_message_post(:save => false))
        post :create, :message_post => {:these => 'params'}
        assigns[:message_post].should equal(mock_message_post)
      end

      it "re-renders the 'new' template" do
        MessagePost.stub!(:new).and_return(mock_message_post(:save => false))
        post :create, :message_post => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested message_post" do
        MessagePost.should_receive(:find).with("37").and_return(mock_message_post)
        mock_message_post.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :message_post => {:these => 'params'}
      end

      it "assigns the requested message_post as @message_post" do
        MessagePost.stub!(:find).and_return(mock_message_post(:update_attributes => true))
        put :update, :id => "1"
        assigns[:message_post].should equal(mock_message_post)
      end

      it "redirects to the message_post" do
        MessagePost.stub!(:find).and_return(mock_message_post(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(message_post_url(mock_message_post))
      end
    end

    describe "with invalid params" do
      it "updates the requested message_post" do
        MessagePost.should_receive(:find).with("37").and_return(mock_message_post)
        mock_message_post.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :message_post => {:these => 'params'}
      end

      it "assigns the message_post as @message_post" do
        MessagePost.stub!(:find).and_return(mock_message_post(:update_attributes => false))
        put :update, :id => "1"
        assigns[:message_post].should equal(mock_message_post)
      end

      it "re-renders the 'edit' template" do
        MessagePost.stub!(:find).and_return(mock_message_post(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested message_post" do
      MessagePost.should_receive(:find).with("37").and_return(mock_message_post)
      mock_message_post.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the message_posts list" do
      MessagePost.stub!(:find).and_return(mock_message_post(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(message_posts_url)
    end
  end

end
