require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContentPagesController do

  def mock_content_page(stubs={})
    @mock_content_page ||= mock_model(ContentPage, stubs)
  end

  describe "GET index" do
    it "assigns all content_pages as @content_pages" do
      ContentPage.stub!(:find).with(:all).and_return([mock_content_page])
      get :index
      assigns[:content_pages].should == [mock_content_page]
    end
  end

  describe "GET show" do
    it "assigns the requested content_page as @content_page" do
      ContentPage.stub!(:find).with("37").and_return(mock_content_page)
      get :show, :id => "37"
      assigns[:content_page].should equal(mock_content_page)
    end
  end

  describe "GET new" do
    it "assigns a new content_page as @content_page" do
      ContentPage.stub!(:new).and_return(mock_content_page)
      get :new
      assigns[:content_page].should equal(mock_content_page)
    end
  end

  describe "GET edit" do
    it "assigns the requested content_page as @content_page" do
      ContentPage.stub!(:find).with("37").and_return(mock_content_page)
      get :edit, :id => "37"
      assigns[:content_page].should equal(mock_content_page)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created content_page as @content_page" do
        ContentPage.stub!(:new).with({'these' => 'params'}).and_return(mock_content_page(:save => true))
        post :create, :content_page => {:these => 'params'}
        assigns[:content_page].should equal(mock_content_page)
      end

      it "redirects to the created content_page" do
        ContentPage.stub!(:new).and_return(mock_content_page(:save => true))
        post :create, :content_page => {}
        response.should redirect_to(content_page_url(mock_content_page))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved content_page as @content_page" do
        ContentPage.stub!(:new).with({'these' => 'params'}).and_return(mock_content_page(:save => false))
        post :create, :content_page => {:these => 'params'}
        assigns[:content_page].should equal(mock_content_page)
      end

      it "re-renders the 'new' template" do
        ContentPage.stub!(:new).and_return(mock_content_page(:save => false))
        post :create, :content_page => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested content_page" do
        ContentPage.should_receive(:find).with("37").and_return(mock_content_page)
        mock_content_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :content_page => {:these => 'params'}
      end

      it "assigns the requested content_page as @content_page" do
        ContentPage.stub!(:find).and_return(mock_content_page(:update_attributes => true))
        put :update, :id => "1"
        assigns[:content_page].should equal(mock_content_page)
      end

      it "redirects to the content_page" do
        ContentPage.stub!(:find).and_return(mock_content_page(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(content_page_url(mock_content_page))
      end
    end

    describe "with invalid params" do
      it "updates the requested content_page" do
        ContentPage.should_receive(:find).with("37").and_return(mock_content_page)
        mock_content_page.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :content_page => {:these => 'params'}
      end

      it "assigns the content_page as @content_page" do
        ContentPage.stub!(:find).and_return(mock_content_page(:update_attributes => false))
        put :update, :id => "1"
        assigns[:content_page].should equal(mock_content_page)
      end

      it "re-renders the 'edit' template" do
        ContentPage.stub!(:find).and_return(mock_content_page(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested content_page" do
      ContentPage.should_receive(:find).with("37").and_return(mock_content_page)
      mock_content_page.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the content_pages list" do
      ContentPage.stub!(:find).and_return(mock_content_page(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(content_pages_url)
    end
  end

end
