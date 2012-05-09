require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ForumsController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end

  def mock_forum(stubs={})
    @mock_forum ||= mock_model(Forum, stubs.merge({:name => 'cool forum', :message_posts => mock_message_posts}))
  end

  def mock_message_post(stubs={})
    @mock_message_post ||= mock_model(MessagePost, stubs.merge({}))
  end

  def mock_message_posts
    return @mock_message_posts if @mock_message_posts
    @mock_message_posts = mock('message_posts_proxy')
    @mock_message_posts.stub!(:paginate).and_return([mock_message_post].paginate)
    @mock_message_posts
  end

  before do
    ContentPage.should_receive(:get_side_menu).and_return(mock_model(ContentPage))
    ContentPage.should_receive(:get_top_menu).and_return(mock_model(ContentPage))
    controller.stub!(:current_user).and_return(mock_user)
  end



  describe "GET index" do
    it "assigns all forums as @forums" do
      Forum.stub(:all).and_return([mock_forum])
      get :index
      assigns[:forums].should == [mock_forum]
    end
  end

  describe "GET show" do
    before(:each) do
      Forum.stub!(:find).with("37").and_return(mock_forum)
    end
    it "assigns the requested forum as @forum" do
      get :show, :id => "37"
      assigns[:forum].should equal(mock_forum)
    end
    it "can render rss" do
      get :show, :id => "37", :format => :rss
      response.should render_template("show", :format => :rss)
    end
  end

  describe "GET new" do
    it "assigns a new forum as @forum" do
      Forum.stub!(:new).and_return(mock_forum)
      get :new
      assigns[:forum].should equal(mock_forum)
    end
  end

  describe "GET edit" do
    it "assigns the requested forum as @forum" do
      Forum.stub!(:find).with("37").and_return(mock_forum)
      get :edit, :id => "37"
      assigns[:forum].should equal(mock_forum)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created forum as @forum" do
        Forum.stub!(:new).with({'these' => 'params'}).and_return(mock_forum(:save => true))
        post :create, :forum => {:these => 'params'}
        assigns[:forum].should equal(mock_forum)
      end

      it "redirects to the created forum" do
        Forum.stub!(:new).and_return(mock_forum(:save => true))
        post :create, :forum => {}
        response.should redirect_to(edit_forum_path(mock_forum))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved forum as @forum" do
        Forum.stub!(:new).with({'these' => 'params'}).and_return(mock_forum(:save => false))
        post :create, :forum => {:these => 'params'}
        assigns[:forum].should equal(mock_forum)
      end

      it "re-renders the 'new' template" do
        Forum.stub!(:new).and_return(mock_forum(:save => false))
        post :create, :forum => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested forum" do
        Forum.should_receive(:find).with("37").and_return(mock_forum)
        mock_forum.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :forum => {:these => 'params'}
      end

      it "assigns the requested forum as @forum" do
        Forum.stub!(:find).and_return(mock_forum(:update_attributes => true))
        put :update, :id => "1"
        assigns[:forum].should equal(mock_forum)
      end

      it "redirects to the forum" do
        Forum.stub!(:find).and_return(mock_forum(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(forum_url(mock_forum))
      end
    end

    describe "with invalid params" do
      it "updates the requested forum" do
        Forum.should_receive(:find).with("37").and_return(mock_forum)
        mock_forum.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :forum => {:these => 'params'}
      end

      it "assigns the forum as @forum" do
        Forum.stub!(:find).and_return(mock_forum(:update_attributes => false))
        put :update, :id => "1"
        assigns[:forum].should equal(mock_forum)
      end

      it "re-renders the 'edit' template" do
        Forum.stub!(:find).and_return(mock_forum(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested forum" do
      Forum.should_receive(:find).with("37").and_return(mock_forum)
      mock_forum.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the forums list" do
      Forum.stub!(:find).and_return(mock_forum(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(forums_url)
    end
  end

end
