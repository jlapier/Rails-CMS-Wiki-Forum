require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPagesController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end

  def mock_wiki(stubs={})
    @mock_wiki ||= mock_model(Wiki, stubs.merge({:title => "some title", :wiki_pages => mock_wiki_pages,
        :wiki_tags => mock_wiki_tags }))
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

  def mock_wiki_tag
    @mock_wiki_tag ||= mock_model(WikiTag)
  end

  def mock_wiki_tags
    return @mock_wiki_tags if @mock_wiki_tags
    @mock_wiki_tags = [ mock_model(WikiTag, :name => "tag A", :wiki_pages_count => 3),
      mock_model(WikiTag, :name => "tag B", :wiki_pages_count => 5) ]
    @mock_wiki_tags
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

    it "assigns a new wiki_page as @wiki_page with a title" do
      get :new, :wiki_id => "12", :title => 'this_is_a_test'
      assigns[:wiki_page].should_not be_nil
      assigns[:wiki_page].should be_an_instance_of WikiPage
      assigns[:wiki_page].title.should == 'this is a test'
    end
  end

  describe "GET history" do
    it "assigns the requested wiki_page as @wiki_page" do
      mock_wiki_page_version_proxy = []
      mock_wiki_page_version_proxy.stub!(:find).and_return([])
      mock_wiki_page.stub!(:versions => mock_wiki_page_version_proxy)
      get :history, :wiki_id => "12", :id => '37'
      assigns[:wiki_page].should equal(mock_wiki_page)
      assigns[:wiki_page_versions].should == []
    end
  end

  describe "GET edit" do
    it "assigns the requested wiki_page as @wiki_page" do
      get :edit, :wiki_id => "12", :id => "37"
      assigns[:wiki_page].should equal(mock_wiki_page)
    end

    it "assigns the requested wiki_page as @wiki_page and sets editing_user" do
      a_time = Time.now
      Time.stub!(:now).and_return(a_time)
      mock_wiki_page.stub!(:editing_user).and_return(nil)
      mock_wiki_page.should_receive(:update_attributes).with({:editing_user => mock_user, :started_editing_at => a_time})
      get :edit, :wiki_id => "12", :id => "37"
      assigns[:wiki_page].should equal(mock_wiki_page)
    end
  end


  describe "GET un_edit" do
    describe "with HTML GET" do
      it "assigns the requested wiki_page as @wiki_page and unmarks it as being edited" do
        mock_wiki_page.should_receive(:update_attributes).with({:editing_user => nil, :started_editing_at => nil})
        get :un_edit, :wiki_id => "12", :id => "37"
        assigns[:wiki_page].should equal(mock_wiki_page)
        response.should redirect_to(wiki_pages_show_by_title_path(mock_wiki, mock_wiki_page.url_title))
      end
    end

    describe "with AJAX GET" do
      it "assigns the requested wiki_page as @wiki_page and unmarks it as being edited" do
        mock_wiki_page.should_receive(:update_attributes).with({:editing_user => nil, :started_editing_at => nil})
        xhr :get, :un_edit, :wiki_id => "12", :id => "37"
        assigns[:wiki_page].should equal(mock_wiki_page)
      end
    end
  end

  describe "GET search" do
    it "searches and assigns wiki pages and wiki tags" do
      mock_wiki_pages.should_receive(:search).with('my search').and_return([mock_wiki_page])
      mock_wiki_tags.should_receive(:search).with('my search').and_return([mock_wiki_tag])

      get :search, :wiki_id => "12", :name => 'my search'
      assigns[:name_part].should == 'my search'
      assigns[:wiki_pages].should == [mock_wiki_page]
      assigns[:wiki_tags].should == [mock_wiki_tag]
    end
  end

  describe "xhr GET upload_handler for rich text editor" do
    it "should write a file and render text output" do
      uploaded_file = mock(ActionController::UploadedStringIO).as_null_object
      uploaded_file.stub!(:original_filename).and_return('test.doc')
      uploaded_file.stub!(:read).and_return("Some content")
      controller.should_receive(:write_file).with(uploaded_file, "wiki_page_assets/wiki_page_#{mock_wiki_page.id}")
      xhr :post, :upload_handler, :wiki_id => "12", :id => '37', :upload => uploaded_file
      assigns[:wiki_page].should equal(mock_wiki_page)
      response.should have_text(/parent.CKEDITOR.tools.callFunction/)
    end
  end

  describe "GET page_link_handler" do
    it "should return the current wiki page and all other wiki pages" do
      other_mock_wiki = stub_model(Wiki, :wiki_pages => mock_wiki_pages)
      Wiki.stub!(:find).with("2").and_return(other_mock_wiki)
      mock_wiki_pages.should_receive(:find).with('31').and_return(mock_wiki_page)
      get :page_link_handler, :wiki_id => "2", :id => '31'
      assigns[:wiki_page].should equal(mock_wiki_page)
      assigns[:wiki_pages].should equal(mock_wiki_pages)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created wiki_page as @wiki_page" do
        WikiPage.stub!(:new).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => true)
        post :create, :wiki_id => "12", :wiki_page => {:these => 'params'}
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "redirects to the created wiki_page in edit mode" do
        WikiPage.stub!(:new).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => true, :wiki= => nil)
        post :create, :wiki_id => "12", :wiki_page => {}
        response.should redirect_to(edit_wiki_wiki_page_url(mock_wiki, mock_wiki_page))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wiki_page as @wiki_page" do
        WikiPage.stub!(:new).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => false, :wiki= => nil)
        post :create, :wiki_id => "12", :wiki_page => {:these => 'params'}
        assigns[:wiki_page].should equal(mock_wiki_page)
      end

      it "re-renders the 'new' template" do
        WikiPage.stub!(:new).and_return(mock_wiki_page)
        mock_wiki_page.stub!(:save => false, :wiki= => nil)
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
        response.should redirect_to(wiki_pages_show_by_title_url(mock_wiki, mock_wiki_page.url_title))
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


  describe "POST delete_asset" do
    it "should delete a file and redirect" do
      File.stub(:exists?).and_return true
      File.stub(:delete).and_return true
      post :delete_asset, :wiki_id => "12", :id => "37", :asset => 'somefile.doc'
      response.should redirect_to(edit_wiki_wiki_page_url(mock_wiki, mock_wiki_page))
    end

    it "should give an error if file not found and redirect" do
      File.stub(:exists?).and_return false
      File.stub(:delete).and_return true
      post :delete_asset, :wiki_id => "12", :id => "37", :asset => 'somefile.doc'
      response.should redirect_to(edit_wiki_wiki_page_url(mock_wiki, mock_wiki_page))
    end
  end

end
