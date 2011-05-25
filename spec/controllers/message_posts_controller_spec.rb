require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagePostsController do
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end

  def mock_forum(stubs={})
    @mock_forum ||= mock_model(Forum, {:name => 'cool forum', :message_posts => mock_message_posts}.merge(stubs) )
  end

  def mock_message_post(stubs={})
    @mock_message_post ||= mock_model(MessagePost, stubs.merge({:thread => nil, :user => mock_user,
          :child_posts => [], :subject => 'blah' }) )
  end

  def mock_message_posts
    return @mock_message_posts if @mock_message_posts
    @mock_message_posts = mock('message_posts_proxy')
    @mock_message_posts.stub!(:paginate).and_return([mock_message_post].paginate)
    #@mock_message_posts.stub!(:find).with('37').and_return(mock_message_post)
    MessagePost.stub(:find).with('37'){ mock_message_post }
    @mock_message_posts
  end

  before do
    ContentPage.should_receive(:get_side_menu).and_return(mock_model(ContentPage))
    ContentPage.should_receive(:get_top_menu).and_return(mock_model(ContentPage))
    controller.stub!(:current_user).and_return(mock_user)
    Forum.stub!(:find).with('12').and_return(mock_forum)
  end

  describe "GET index" do
    it "redirects to forum" do
      get :index, :forum_id => '12'
      response.should redirect_to(forum_url(mock_forum))
    end
  end

  describe "GET show" do
    it "assigns the requested message_post as @message_post" do
      get :show, :forum_id => "12", :id => "37"
      assigns[:message_post].should equal(mock_message_post)
    end
    it "can render rss" do
      get :show, :forum_id => "12", :id => "37", :format => :rss
      response.should render_template("show", :format => :rss)
    end
  end

  describe "GET new" do
    it "assigns a new message_post as @message_post" do
      MessagePost.stub!(:new).and_return(mock_message_post)
      get :new, :forum_id => "12"
      assigns[:message_post].should equal(mock_message_post)
    end
  end

  describe "GET edit" do
    it "assigns the requested message_post as @message_post" do
      MessagePost.stub!(:find).with("37").and_return(mock_message_post)
      get :edit, :forum_id => "12", :id => "37"
      assigns[:message_post].should equal(mock_message_post)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created message_post as @message_post" do
        MessagePost.stub!(:new).with({'these' => 'params'}).and_return(mock_message_post(:save => true, :forum= => nil, :user= => nil))
        mock_message_post.stub(:save => true, :forum= => nil, :user= => nil)
        post :create, :forum_id => "12", :message_post => {:these => 'params'}
        assigns[:message_post].should equal(mock_message_post)
      end

      it "redirects to the created message_post" do
        MessagePost.stub!(:new).and_return(mock_message_post(:save => true, :forum= => nil, :user= => nil))
        mock_message_post.stub(:save => true, :forum= => nil, :user= => nil)
        post :create, :forum_id => "12", :message_post => {}
        response.should redirect_to(forum_message_post_url(mock_forum, mock_message_post))
      end
    end

    describe "with valid params and a thread_id" do
      it "assigns a newly created message_post as @message_post and assigns no forum" do
        mock_child_posts = []
        mock_child_posts.stub(:last_page_number_for).and_return(1)
        mock_message_thread = mock_model(MessagePost, :child_posts => mock_child_posts)
        new_mock_message_post = mock_model(MessagePost, :thread => mock_message_thread, :user => mock_user,
          :child_posts => [], :subject => 'blah2', :save => true, :user= => nil)
        MessagePost.stub!(:new).with({'these' => 'params'}).and_return(new_mock_message_post)
        new_mock_message_post.should_not_receive(:forum=)
        post :create, :forum_id => "12", :message_post => {:these => 'params'}
        assigns[:message_post].should equal(new_mock_message_post)
      end

      it "redirects to the created message_post" do
        mock_child_posts = []
        mock_child_posts.stub(:last_page_number_for).and_return(1)
        mock_message_thread = mock_model(MessagePost, :child_posts => mock_child_posts)
        new_mock_message_post = mock_model(MessagePost, :thread => mock_message_thread, :user => mock_user,
          :child_posts => [], :subject => 'blah2', :save => true, :user= => nil)
        MessagePost.stub!(:new).with({'these' => 'params'}).and_return(new_mock_message_post)
        post :create, :forum_id => "12", :message_post => {:these => 'params'}
        response.should redirect_to(forum_message_post_url(mock_forum, mock_message_thread, :anchor => new_mock_message_post.id,
              :page => 1))
      end
    end


    describe "with invalid params" do
      it "assigns a newly created but unsaved message_post as @message_post" do
        MessagePost.stub!(:new).with({'these' => 'params'}).and_return(mock_message_post(:save => false, :forum= => nil, :user= => nil))
        mock_message_post.stub(:save => false, :forum= => nil, :user= => nil)
        post :create, :forum_id => "12", :message_post => {:these => 'params'}
        assigns[:message_post].should equal(mock_message_post)
      end

      it "re-renders the 'new' template" do
        MessagePost.stub!(:new).and_return(mock_message_post(:save => false, :forum= => nil, :user => nil))
        mock_message_post.stub(:save => false, :forum= => nil, :user= => nil)
        post :create, :forum_id => "12", :message_post => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested message_post" do
        mock_message_posts.stub!(:find).with("37").and_return(mock_message_post)
        mock_message_post.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :forum_id => "12", :id => "37", :message_post => {:these => 'params'}
      end

      it "assigns the requested message_post as @message_post" do
        mock_message_posts.stub!(:find).with('37').and_return(mock_message_post(:update_attributes => true))
        mock_message_post.stub!(:update_attributes => true)
        put :update, :forum_id => "12", :id => "37"
        assigns[:message_post].should equal(mock_message_post)
      end

      it "redirects to the message_post" do
        mock_message_posts.stub!(:find).and_return(mock_message_post(:update_attributes => true))
        mock_message_post.stub!(:update_attributes => true)
        put :update, :forum_id => "12", :id => "37"
        response.should redirect_to(forum_message_post_url(mock_forum, mock_message_post))
      end
    end

    describe "with invalid params" do
      it "updates the requested message_post" do
        mock_message_post.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :forum_id => "12", :id => "37", :message_post => {:these => 'params'}
      end

      it "assigns the message_post as @message_post" do
        mock_message_posts.stub!(:find).and_return(mock_message_post(:update_attributes => false))
        mock_message_post.stub!(:update_attributes => false)
        put :update, :forum_id => "12", :id => "37"
        assigns[:message_post].should equal(mock_message_post)
      end

      it "re-renders the 'edit' template" do
        mock_message_posts.stub!(:find).and_return(mock_message_post(:update_attributes => false))
        mock_message_post.stub!(:update_attributes => false)
        put :update, :forum_id => "12", :id => "37"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested message_post" do
      mock_message_post.should_receive(:destroy)
      delete :destroy, :forum_id => "12", :id => "37"
    end

    it "redirects to the message_posts list" do
      mock_message_posts.stub!(:find).and_return(mock_message_post(:destroy => true))
      mock_message_post.stub!(:destroy => true)
      delete :destroy, :forum_id => "12", :id => "37"
      response.should redirect_to(forum_url(mock_forum))
    end
  end

end
