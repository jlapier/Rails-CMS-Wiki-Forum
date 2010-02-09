require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPagesController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end

  def mock_wiki(stubs={})
    @mock_wiki ||= mock_model(Wiki, stubs.merge({:title => "some title", :wiki_pages => mock_wiki_pages}))
  end

  def mock_wiki_page(stubs={})
    @mock_wiki_page ||= mock_model(WikiPage, stubs.merge({:title => "some title", :editing_user => mock_user,
        :url_title => 'some_title',
        :editing_user= => nil, :modifying_user= => nil}))
  end

  def mock_wiki_pages
    return @mock_wiki_pages if @mock_wiki_pages
    @mock_wiki_pages = mock('wiki_page_proxy')
    @mock_wiki_pages.stub!(:paginate).and_return([mock_wiki_page].paginate)
    @mock_wiki_pages.stub!(:find).with('37').and_return(mock_wiki_page)
    @mock_wiki_pages
  end

  before do
    ContentPage.should_receive(:get_side_menu).and_return(mock_model(ContentPage))
    ContentPage.should_receive(:get_top_menu).and_return(mock_model(ContentPage))
    controller.stub!(:current_user).and_return(mock_user)
    Wiki.stub!(:find).with("12").and_return(mock_wiki)
  end


  describe "GET index" do
    it "redirects to wiki index" do
      get :index, :wiki_id => "12"
      response.should redirect_to(wiki_url(mock_wiki))
    end
  end

  describe "GET show" do
    it "assigns the requested wiki_page as @wiki_page" do
      get :show, :wiki_id => "12", :id => "37"
      assigns[:wiki_page].should equal(mock_wiki_page)
    end
  end

  describe "GET new" do
    it "assigns a new wiki_page as @wiki_page" do
      WikiPage.stub!(:new).and_return(mock_wiki_page)
      get :new, :wiki_id => "12"
      assigns[:wiki_page].should equal(mock_wiki_page)
    end
  end

  describe "GET edit" do
    it "assigns the requested wiki_page as @wiki_page" do
      get :edit, :wiki_id => "12", :id => "37"
      assigns[:wiki_page].should equal(mock_wiki_page)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created wiki_page as @wiki_page" do
        WikiPage.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => true)
        post :create, :wiki_id => "12", :wiki_page => {:these => 'params'}
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "redirects to the created wiki_page in edit mode" do
        WikiPage.stub!(:new).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => true)
        post :create, :wiki_id => "12", :wiki_page => {}
        response.should redirect_to(edit_wiki_wiki_page_url(mock_wiki, mock_wiki_page))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wiki_page as @wiki_page" do
        WikiPage.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => false)
        post :create, :wiki_id => "12", :wiki_page => {:these => 'params'}
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "re-renders the 'new' template" do
        WikiPage.stub!(:new).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => false)
        post :create, :wiki_id => "12", :wiki_page => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested wiki_page" do
        mock_wiki_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :wiki_id => "12", :id => "37", :wiki_page => {:these => 'params'}
      end

      it "assigns the requested wiki_page as @wiki_page" do
        mock_wiki_page.stub!(:update_attributes => true)
        put :update, :wiki_id => "12", :id => "37"
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "redirects to the wiki_page" do
        mock_wiki_page.stub!(:update_attributes => true)
        put :update, :wiki_id => "12", :id => "37"
        response.should redirect_to(wiki_show_by_title_url(mock_wiki, :title => mock_wiki_page.url_title))
      end
    end

    describe "with invalid params" do
      it "updates the requested wiki_page" do
        mock_wiki_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :wiki_id => "12", :id => "37", :wiki_page => {:these => 'params'}
      end

      it "assigns the wiki_page as @wiki_page" do
        mock_wiki_page.stub!(:update_attributes => false)
        put :update, :wiki_id => "12", :id => "37"
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "re-renders the 'edit' template" do
        mock_wiki_page.stub!(:update_attributes => false)
        put :update, :wiki_id => "12", :id => "37"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested wiki_page" do
      mock_wiki_page.should_receive(:destroy)
      delete :destroy, :wiki_id => "12", :id => "37"
    end

    it "redirects to the wiki show page" do
      mock_wiki_page.stub!(:destroy => true)
      delete :destroy, :wiki_id => "12", :id => "37"
      response.should redirect_to(wiki_url(mock_wiki))
    end
  end

end
