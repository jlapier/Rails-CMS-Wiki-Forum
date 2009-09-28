require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPagesController do

  def mock_wiki_page(stubs={})
    @mock_wiki_page ||= mock_model(WikiPage, stubs)
  end

  describe "GET index" do
    it "assigns all wiki_pages as @wiki_pages" do
      WikiPage.stub!(:find).with(:all).and_return([mock_wiki_page])
      get :index
      assigns[:wiki_pages].should == [mock_wiki_page]
    end
  end

  describe "GET show" do
    it "assigns the requested wiki_page as @wiki_page" do
      WikiPage.stub!(:find).with("37").and_return(mock_wiki_page)
      get :show, :id => "37"
      assigns[:wiki_page].should equal(mock_wiki_page)
    end
  end

  describe "GET new" do
    it "assigns a new wiki_page as @wiki_page" do
      WikiPage.stub!(:new).and_return(mock_wiki_page)
      get :new
      assigns[:wiki_page].should equal(mock_wiki_page)
    end
  end

  describe "GET edit" do
    it "assigns the requested wiki_page as @wiki_page" do
      WikiPage.stub!(:find).with("37").and_return(mock_wiki_page)
      get :edit, :id => "37"
      assigns[:wiki_page].should equal(mock_wiki_page)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created wiki_page as @wiki_page" do
        WikiPage.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_page(:save => true))
        post :create, :wiki_page => {:these => 'params'}
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "redirects to the created wiki_page" do
        WikiPage.stub!(:new).and_return(mock_wiki_page(:save => true))
        post :create, :wiki_page => {}
        response.should redirect_to(wiki_page_url(mock_wiki_page))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wiki_page as @wiki_page" do
        WikiPage.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_page(:save => false))
        post :create, :wiki_page => {:these => 'params'}
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "re-renders the 'new' template" do
        WikiPage.stub!(:new).and_return(mock_wiki_page(:save => false))
        post :create, :wiki_page => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested wiki_page" do
        WikiPage.should_receive(:find).with("37").and_return(mock_wiki_page)
        mock_wiki_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :wiki_page => {:these => 'params'}
      end

      it "assigns the requested wiki_page as @wiki_page" do
        WikiPage.stub!(:find).and_return(mock_wiki_page(:update_attributes => true))
        put :update, :id => "1"
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "redirects to the wiki_page" do
        WikiPage.stub!(:find).and_return(mock_wiki_page(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(wiki_page_url(mock_wiki_page))
      end
    end

    describe "with invalid params" do
      it "updates the requested wiki_page" do
        WikiPage.should_receive(:find).with("37").and_return(mock_wiki_page)
        mock_wiki_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :wiki_page => {:these => 'params'}
      end

      it "assigns the wiki_page as @wiki_page" do
        WikiPage.stub!(:find).and_return(mock_wiki_page(:update_attributes => false))
        put :update, :id => "1"
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "re-renders the 'edit' template" do
        WikiPage.stub!(:find).and_return(mock_wiki_page(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested wiki_page" do
      WikiPage.should_receive(:find).with("37").and_return(mock_wiki_page)
      mock_wiki_page.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the wiki_pages list" do
      WikiPage.stub!(:find).and_return(mock_wiki_page(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(wiki_pages_url)
    end
  end

end
