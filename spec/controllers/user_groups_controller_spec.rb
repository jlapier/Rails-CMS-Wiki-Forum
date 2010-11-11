require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserGroupsController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true, :email => 'bob@bob.com'}))
  end

  def mock_other_user(stubs={})
    @mock_other_user ||= mock_model(User, stubs.merge({:email => 'joe@joe.com'}))
  end

  def mock_user_group(stubs={})
    @mock_user_group ||= mock_model(UserGroup, stubs.merge(:name => "some group"))
  end

  before do
    ContentPage.should_receive(:get_side_menu).and_return(mock_model(ContentPage))
    ContentPage.should_receive(:get_top_menu).and_return(mock_model(ContentPage))
    controller.stub!(:current_user).and_return(mock_user)
  end

  describe "GET index" do
    it "assigns all user_groups as @user_groups" do
      UserGroup.stub(:all).and_return([mock_user_group])
      get :index
      assigns[:user_groups].should == [mock_user_group]
    end
  end

  describe "GET show" do
    it "assigns the requested user_group as @user_group" do
      UserGroup.stub!(:find).with("37").and_return(mock_user_group)
      get :show, :id => "37"
      assigns[:user_group].should equal(mock_user_group)
    end
  end

  describe "GET new" do
    it "assigns a new user_group as @user_group" do
      UserGroup.stub!(:new).and_return(mock_user_group)
      get :new
      assigns[:user_group].should equal(mock_user_group)
    end
  end

  describe "GET edit" do
    it "assigns the requested user_group as @user_group" do
      UserGroup.stub!(:find).with("37").and_return(mock_user_group)
      get :edit, :id => "37"
      assigns[:user_group].should equal(mock_user_group)
    end
  end

  describe "GET emails" do
    it "redirects if html request" do
      get :emails, :user_group_ids => ["1"]
      response.should redirect_to(user_groups_url)
    end

    it "returns emails if json request" do
      mock_user.should_receive(:email).and_return 'bob@bob.com'
      mock_user_group.stub!(:users).and_return([mock_user, mock_other_user])
      mock_group_two = mock_model(UserGroup, :name => "group two")
      mock_group_two.stub!(:users).and_return([mock_other_user])
      UserGroup.stub!(:find).and_return([mock_user_group, mock_group_two])
      get :emails, :format => 'js', :user_group_ids => ["1"]
      response.should be_success
      response.body.should == '["bob@bob.com","joe@joe.com"]'
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created user_group as @user_group" do
        UserGroup.stub!(:new).with({'these' => 'params'}).and_return(mock_user_group(:save => true))
        post :create, :user_group => {:these => 'params'}
        assigns[:user_group].should equal(mock_user_group)
      end

      it "redirects to the created user_group" do
        UserGroup.stub!(:new).and_return(mock_user_group(:save => true))
        post :create, :user_group => {}
        response.should redirect_to(user_group_url(mock_user_group))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user_group as @user_group" do
        UserGroup.stub!(:new).with({'these' => 'params'}).and_return(mock_user_group(:save => false))
        post :create, :user_group => {:these => 'params'}
        assigns[:user_group].should equal(mock_user_group)
      end

      it "re-renders the 'new' template" do
        UserGroup.stub!(:new).and_return(mock_user_group(:save => false))
        post :create, :user_group => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested user_group" do
        UserGroup.should_receive(:find).with("37").and_return(mock_user_group)
        mock_user_group.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user_group => {:these => 'params'}
      end

      it "assigns the requested user_group as @user_group" do
        UserGroup.stub!(:find).and_return(mock_user_group(:update_attributes => true))
        put :update, :id => "1"
        assigns[:user_group].should equal(mock_user_group)
      end

      it "redirects to the user_group" do
        UserGroup.stub!(:find).and_return(mock_user_group(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(user_group_url(mock_user_group))
      end
    end

    describe "with invalid params" do
      it "updates the requested user_group" do
        UserGroup.should_receive(:find).with("37").and_return(mock_user_group)
        mock_user_group.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user_group => {:these => 'params'}
      end

      it "assigns the user_group as @user_group" do
        UserGroup.stub!(:find).and_return(mock_user_group(:update_attributes => false))
        put :update, :id => "1"
        assigns[:user_group].should equal(mock_user_group)
      end

      it "re-renders the 'edit' template" do
        UserGroup.stub!(:find).and_return(mock_user_group(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested user_group" do
      UserGroup.should_receive(:find).with("37").and_return(mock_user_group)
      mock_user_group.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the user_groups list" do
      UserGroup.stub!(:find).and_return(mock_user_group(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(user_groups_url)
    end
  end

end
