require 'spec_helper'

describe WikisController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true, :name => 'Name'}))
  end

  def mock_user_group
    @mock_user_group ||= mock_model(UserGroup, :users => [mock_user])
  end

  def mock_wiki(stubs={})
    @mock_wiki ||= mock_model(Wiki, stubs.merge({:title => "some title", :wiki_pages => mock_wiki_pages}))
  end

  def mock_wiki_page(stubs={})
    @mock_wiki_page ||= mock_model(WikiPage, stubs.merge({:title => "some title"}))
  end

  def mock_wiki_pages
    return @mock_wiki_pages if @mock_wiki_pages
    @mock_wiki_pages = mock('wiki_page_proxy')
    @mock_wiki_pages.stub!(:paginate).and_return([mock_wiki_page].paginate)
    @mock_wiki_pages
  end

  before do
    ContentPage.should_receive(:get_side_menu).and_return(mock_model(ContentPage))
    ContentPage.should_receive(:get_top_menu).and_return(mock_model(ContentPage))
    controller.stub!(:current_user).and_return(mock_user)
  end

  describe "GET index" do
    it "assigns all wikis as @wikis" do
      Wiki.stub(:find).with(:all, :order => "name").and_return([mock_wiki])
      get :index
      assigns[:wikis].should == [mock_wiki]
    end
  end

  describe "GET show" do
    it "assigns the requested wiki as @wiki if access" do
      mock_user.stub(:has_read_access_to?).and_return(true)
      Wiki.stub(:find).with("37").and_return(mock_wiki)
      get :show, :id => "37"
      assigns[:wiki].should equal(mock_wiki)
    end

    it "redirects if no access to requested wiki" do
      mock_user.stub(:has_read_access_to?).and_return(false)
      Wiki.stub(:find).with("37").and_return(mock_wiki)
      get :show, :id => "37"
      response.should redirect_to(wikis_url)
    end
  end

  describe "GET new" do
    it "assigns a new wiki as @wiki" do
      Wiki.stub(:new).and_return(mock_wiki)
      get :new
      assigns[:wiki].should equal(mock_wiki)
    end
  end

  describe "GET edit" do
    it "assigns the requested wiki as @wiki" do
      Wiki.stub(:find).with("37").and_return(mock_wiki)
      get :edit, :id => "37"
      assigns[:wiki].should equal(mock_wiki)
    end
  end

  describe "GET tagcloud" do
    it "assigns wiki_tags as @wiki_tags" do
      mock_user.stub(:has_read_access_to?).and_return(true)
      Wiki.stub(:find).with("37").and_return(mock_wiki)
      mock_wiki_tags = [ mock_model(WikiTag, :name => "tag A", :wiki_pages_count => 3),
        mock_model(WikiTag, :name => "tag B", :wiki_pages_count => 5) ]
      mock_wiki.stub(:wiki_tags).and_return(mock_wiki_tags)
      xhr :get, :tagcloud, :id => "37"
      assigns[:wiki].should equal(mock_wiki)
      assigns[:wiki_tags].should == mock_wiki_tags
    end
  end

  describe "GET list_by_tag" do
    it "assigns wiki_pages as @wiki_pages" do
      mock_user.stub(:has_read_access_to?).and_return(true)
      Wiki.stub(:find).with("37").and_return(mock_wiki)
      UserGroup.stub(:find_all_with_access_to).and_return([mock_user_group])
      mock_wiki_tag = mock_model(WikiTag, :name => "tag A", :wiki_pages_count => 3, :wiki_pages => mock_wiki_pages)
      mock_wiki_tags = [ mock_wiki_tag ]
      mock_wiki.stub(:wiki_tags).and_return(mock_wiki_tags)
      mock_wiki_tags.should_receive(:find).with(:first, :conditions => { :name => "tag A"}).and_return(mock_wiki_tag)
      get :list_by_tag, :id => "37", :tag_name => 'tag A'
      assigns[:wiki].should equal(mock_wiki)
      assigns[:wiki_tag].should equal(mock_wiki_tag)
      assigns[:wiki_pages].should == [mock_wiki_page].paginate
      assigns[:users_with_access].should == [mock_user]
    end

    it "redirects if tag not found" do
      mock_user.stub(:has_read_access_to?).and_return(true)
      Wiki.stub(:find).with("37").and_return(mock_wiki)
      mock_wiki_tags = []
      mock_wiki.stub(:wiki_tags).and_return(mock_wiki_tags)
      mock_wiki_tags.should_receive(:find).with(:first, :conditions => { :name => "tag Not"}).and_return(nil)
      get :list_by_tag, :id => "37", :tag_name => 'tag Not'
      flash[:warning].should == "Tag not found."
      response.should redirect_to(wiki_url(mock_wiki))
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created wiki as @wiki" do
        Wiki.stub(:new).with({'these' => 'params'}).and_return(mock_wiki(:save => true))
        post :create, :wiki => {:these => 'params'}
        assigns[:wiki].should equal(mock_wiki)
      end

      it "redirects to the created wiki" do
        Wiki.stub(:new).and_return(mock_wiki(:save => true))
        post :create, :wiki => {}
        response.should redirect_to(wiki_url(mock_wiki))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wiki as @wiki" do
        Wiki.stub(:new).with({'these' => 'params'}).and_return(mock_wiki(:save => false))
        post :create, :wiki => {:these => 'params'}
        assigns[:wiki].should equal(mock_wiki)
      end

      it "re-renders the 'new' template" do
        Wiki.stub(:new).and_return(mock_wiki(:save => false))
        post :create, :wiki => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested wiki" do
        Wiki.should_receive(:find).with("37").and_return(mock_wiki)
        mock_wiki.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :wiki => {:these => 'params'}
      end

      it "assigns the requested wiki as @wiki" do
        Wiki.stub(:find).and_return(mock_wiki(:update_attributes => true))
        put :update, :id => "1"
        assigns[:wiki].should equal(mock_wiki)
      end

      it "redirects to the wiki" do
        Wiki.stub(:find).and_return(mock_wiki(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(wiki_url(mock_wiki))
      end
    end

    describe "with invalid params" do
      it "updates the requested wiki" do
        Wiki.should_receive(:find).with("37").and_return(mock_wiki)
        mock_wiki.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :wiki => {:these => 'params'}
      end

      it "assigns the wiki as @wiki" do
        Wiki.stub(:find).and_return(mock_wiki(:update_attributes => false))
        put :update, :id => "1"
        assigns[:wiki].should equal(mock_wiki)
      end

      it "re-renders the 'edit' template" do
        Wiki.stub(:find).and_return(mock_wiki(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested wiki" do
      Wiki.should_receive(:find).with("37").and_return(mock_wiki)
      mock_wiki.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the wikis list" do
      Wiki.stub(:find).and_return(mock_wiki(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(wikis_url)
    end
  end

end
