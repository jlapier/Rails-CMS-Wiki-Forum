require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiCommentsController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end

  def mock_wiki(stubs={})
    @mock_wiki ||= mock_model(Wiki, stubs.merge({:title => "some title", :wiki_comments => mock_wiki_comments}))
  end

  def mock_wiki_page(stubs={})
    @mock_wiki_page ||= mock_model(WikiPage, stubs.merge({:title => "some title", :editing_user => mock_user,
        :url_title => 'some_title', :version => 5,
        :editing_user= => nil, :modifying_user= => nil}))
  end

  def mock_wiki_comments
    return @mock_wiki_comments if @mock_wiki_comments
    @mock_wiki_comments = mock('wiki_comment_proxy')
    @mock_wiki_comments.stub!(:paginate).and_return([mock_wiki_comment].paginate)
    @mock_wiki_comments.stub!(:find).with('37').and_return(mock_wiki_comment)
    @mock_wiki_comments
  end

  def mock_wiki_comment(stubs={})
    @mock_wiki_comment ||= mock_model(WikiComment, stubs.merge({ :wiki_page => mock_wiki_page, :wiki => mock_wiki,
          :user => mock_user, :user= => nil }))
  end

  before do
    ContentPage.should_receive(:get_side_menu).and_return(mock_model(ContentPage))
    ContentPage.should_receive(:get_top_menu).and_return(mock_model(ContentPage))
    controller.stub!(:current_user).and_return(mock_user)
    Wiki.stub!(:find).with("12").and_return(mock_wiki)
    WikiComment.stub!(:get_digest).and_return([mock_wiki_comment])
  end
  
  describe "GET index" do
    it "assigns all wiki_comments as @wiki_comments" do
      get :index, :wiki_id => "12"
      assigns[:comments].should == [mock_wiki_comment]
    end
  end

  describe "GET daily" do
    it "assigns daily wiki_comments as @wiki_comments" do
      get :daily, :wiki_id => "12"
      assigns[:comments].should == [mock_wiki_comment]
    end
  end

  describe "GET weekly" do
    it "assigns weekly wiki_comments as @wiki_comments" do
      get :weekly, :wiki_id => "12"
      assigns[:comments].should == [mock_wiki_comment]
    end
  end

  describe "GET daily.atom" do
    it "assigns daily wiki_comments as @wiki_comments" do
      get :daily, :wiki_id => "12", :format => 'atom'
      assigns[:comments].should == [mock_wiki_comment]
    end
  end

  describe "GET weekly.atom" do
    it "assigns weekly wiki_comments as @wiki_comments" do
      get :weekly, :wiki_id => "12", :format => 'atom'
      assigns[:comments].should == [mock_wiki_comment]
    end
  end

  describe "GET show" do
    it "redirects to the wiki page" do
      get :show, :id => "37", :wiki_id => "12"
      response.should redirect_to(wiki_wiki_page_url(mock_wiki, mock_wiki_page))
    end
  end

  describe "POST create" do

    describe "with valid params" do
      describe "when an HTML post" do
        it "assigns a newly created wiki_comment as @wiki_comment" do
          WikiComment.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_comment)
          mock_wiki_comment.should_receive(:save).and_return(true)
          post :create, :wiki_comment => {:these => 'params'}, :wiki_id => "12"
        end

        it "redirects to the created wiki_comment" do
          WikiComment.stub!(:new).and_return(mock_wiki_comment)
          mock_wiki_comment.should_receive(:save).and_return(true)
          post :create, :wiki_comment => {}, :wiki_id => "12"
          response.should redirect_to(wiki_wiki_page_url(mock_wiki, mock_wiki_page))
        end
      end

      describe "when an AJAX post" do
        it "assigns a newly created wiki_comment as @wiki_comment and render comments partial" do
          new_wiki_comment = stub_model(WikiComment)
          WikiComment.stub(:new).once.with({'these' => 'params'}).and_return(mock_wiki_comment)
          WikiComment.stub(:new).once.with({ :wiki_page_id => mock_wiki_page.id, :looking_at_version => mock_wiki_page.version,
            :url => wiki_wiki_comments_path(mock_wiki)}).and_return(new_wiki_comment)
          mock_wiki_comment.should_receive(:save).and_return(true)
          # this is ridiculous but I kept getting an error rendering the partial via RJS
          controller.stub(:render)
          xhr :post, :create, :wiki_comment => {:these => 'params'}, :wiki_id => "12"
        end
      end
    end

    describe "with invalid params" do
      describe "when an HTML post" do
        it "assigns a newly created but unsaved wiki_comment as @wiki_comment" do
          WikiComment.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_comment)
          errors = []
          errors.stub!(:full_messages).and_return(['blah', 'boo'])
          mock_wiki_comment.should_receive(:save).and_return(false)
          mock_wiki_comment.should_receive(:errors).and_return(errors)
          post :create, :wiki_comment => {:these => 'params'}, :wiki_id => "12"
        end

        it "redirects back to the wiki page" do
          WikiComment.stub!(:new).and_return(mock_wiki_comment)
          errors = []
          errors.stub!(:full_messages).and_return(['blah', 'boo'])
          mock_wiki_comment.should_receive(:save).and_return(false)
          mock_wiki_comment.should_receive(:errors).and_return(errors)
          post :create, :wiki_comment => {}, :wiki_id => "12"
          response.should redirect_to(wiki_wiki_page_url(mock_wiki, mock_wiki_page))
        end
      end

      describe "when an AJAX post" do
        it "renders an error in the message box" do
          WikiComment.stub!(:new).and_return(mock_wiki_comment)
          errors = []
          errors.stub!(:full_messages).and_return(['blah', 'boo'])
          mock_wiki_comment.should_receive(:save).and_return(false)
          mock_wiki_comment.should_receive(:errors).and_return(errors)
          xhr :post, :create, :wiki_comment => {}, :wiki_id => "12"
          response.should have_text(/Unable to save comment/)
        end
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested wiki_comment" do
      mock_wiki_comment.should_receive(:destroy)
      delete :destroy, :id => "37", :wiki_id => "12"
    end

    it "redirects to the wiki_page" do
      mock_wiki_comment.should_receive(:destroy).and_return(true)
      delete :destroy, :id => "37", :wiki_id => "12"
      response.should redirect_to(wiki_wiki_page_url(mock_wiki, mock_wiki_page))
    end
  end

end
