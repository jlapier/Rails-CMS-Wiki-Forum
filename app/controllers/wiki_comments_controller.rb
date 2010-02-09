class WikiCommentsController < ApplicationController
  before_filter :get_wiki
  before_filter :require_wiki_read_access, :only => [:index, :create]

  def index
    @comments = @wiki.wiki_comments.paginate :all, :include => :user, :limit => 40, :order => "created_at DESC"
    respond_to do |format|
      format.html
      format.atom
    end
  end

  def daily
    @comments = WikiComment.get_digest @wiki

    respond_to do |format|
      format.html { render :action => :index }
      format.atom { render :action => :index }
    end
  end

  def weekly
    @comments = WikiComment.get_digest @wiki, 'week'
    
    respond_to do |format|
      format.html { render :action => :index }
      format.atom { render :action => :index }
    end
  end

  def show
    wiki_comment = @wiki.wiki_comments.find params[:id]
    @wiki_page = wiki_comment.wiki_page
    if @wiki_page
      redirect_to wiki_wiki_page_path(@wiki, @wiki_page)
    else
      redirect_to wiki_wiki_comments_path(@wiki)
    end
  end

  def create
    wiki_comment = WikiComment.new params[:wiki_comment]
    wiki_comment.user = current_user
    @wiki_page = wiki_comment.wiki_page
    if wiki_comment.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Comment posted."
          redirect_to wiki_wiki_page_path(@wiki, @wiki_page)
        end
        format.js do
          render :update do |page|
            page[:comments].replace_html :partial => '/wiki_pages/comments'
            page[:comments].visual_effect :highlight
          end
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = "Unable to save comment. Errors: #{wiki_comment.errors.full_messages.join('; ')}"
          if @wiki_page
            redirect_to wiki_wiki_page_path(@wiki, @wiki_page)
          else
            redirect_to wiki_path(@wiki)
          end
        end
        format.js do
          render :update do |page|
            page[:message].update "Unable to save comment. Errors: #{wiki_comment.errors.full_messages.join('; ')}"
          end
        end
      end
    end
  end

  def destroy
    wiki_comment = @wiki.wiki_comments.find params[:id]
    @wiki_page = wiki_comment.wiki_page
    if wiki_comment.user == current_user or current_user.is_admin?
      wiki_comment.destroy
      flash[:notice] = "Comment deleted."
      redirect_to wiki_wiki_page_path(@wiki, @wiki_page)
    end
  end

  private

  def get_wiki
    @wiki = Wiki.find params[:wiki_id]
  end

end
