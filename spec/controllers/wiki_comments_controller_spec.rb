require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiCommentsController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end
  
  def mock_wiki_comment(stubs={})
    @mock_wiki_comment ||= mock_model(WikiComment, stubs)
  end

  describe "GET index" do
    it "assigns all wiki_comments as @wiki_comments" do
      WikiComment.stub!(:find).with(:all).and_return([mock_wiki_comment])
      get :index
      assigns[:wiki_comments].should == [mock_wiki_comment]
    end
  end

  describe "GET show" do
    it "assigns the requested wiki_comment as @wiki_comment" do
      WikiComment.stub!(:find).with("37").and_return(mock_wiki_comment)
      get :show, :id => "37"
      assigns[:wiki_comment].should equal(mock_wiki_comment)
    end
  end

  describe "GET new" do
    it "assigns a new wiki_comment as @wiki_comment" do
      WikiComment.stub!(:new).and_return(mock_wiki_comment)
      get :new
      assigns[:wiki_comment].should equal(mock_wiki_comment)
    end
  end

  describe "GET edit" do
    it "assigns the requested wiki_comment as @wiki_comment" do
      WikiComment.stub!(:find).with("37").and_return(mock_wiki_comment)
      get :edit, :id => "37"
      assigns[:wiki_comment].should equal(mock_wiki_comment)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created wiki_comment as @wiki_comment" do
        WikiComment.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_comment(:save => true))
        post :create, :wiki_comment => {:these => 'params'}
        assigns[:wiki_comment].should equal(mock_wiki_comment)
      end

      it "redirects to the created wiki_comment" do
        WikiComment.stub!(:new).and_return(mock_wiki_comment(:save => true))
        post :create, :wiki_comment => {}
        response.should redirect_to(wiki_comment_url(mock_wiki_comment))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wiki_comment as @wiki_comment" do
        WikiComment.stub!(:new).with({'these' => 'params'}).and_return(mock_wiki_comment(:save => false))
        post :create, :wiki_comment => {:these => 'params'}
        assigns[:wiki_comment].should equal(mock_wiki_comment)
      end

      it "re-renders the 'new' template" do
        WikiComment.stub!(:new).and_return(mock_wiki_comment(:save => false))
        post :create, :wiki_comment => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested wiki_comment" do
        WikiComment.should_receive(:find).with("37").and_return(mock_wiki_comment)
        mock_wiki_comment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :wiki_comment => {:these => 'params'}
      end

      it "assigns the requested wiki_comment as @wiki_comment" do
        WikiComment.stub!(:find).and_return(mock_wiki_comment(:update_attributes => true))
        put :update, :id => "1"
        assigns[:wiki_comment].should equal(mock_wiki_comment)
      end

      it "redirects to the wiki_comment" do
        WikiComment.stub!(:find).and_return(mock_wiki_comment(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(wiki_comment_url(mock_wiki_comment))
      end
    end

    describe "with invalid params" do
      it "updates the requested wiki_comment" do
        WikiComment.should_receive(:find).with("37").and_return(mock_wiki_comment)
        mock_wiki_comment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :wiki_comment => {:these => 'params'}
      end

      it "assigns the wiki_comment as @wiki_comment" do
        WikiComment.stub!(:find).and_return(mock_wiki_comment(:update_attributes => false))
        put :update, :id => "1"
        assigns[:wiki_comment].should equal(mock_wiki_comment)
      end

      it "re-renders the 'edit' template" do
        WikiComment.stub!(:find).and_return(mock_wiki_comment(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested wiki_comment" do
      WikiComment.should_receive(:find).with("37").and_return(mock_wiki_comment)
      mock_wiki_comment.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the wiki_comments list" do
      WikiComment.stub!(:find).and_return(mock_wiki_comment(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(wiki_comments_url)
    end
  end

end
