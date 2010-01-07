class WikiCommentsController < ApplicationController
  def index
    @comments = WikiComment.find :all, :include => :user, :limit => 40, :order => "created_at DESC"
    respond_to do |format|
      format.html
      format.atom
    end
  end

  def daily
    @comments = WikiComment.get_daily_digest

    respond_to do |format|
      format.html { render :action => :index }
      format.atom { render :action => :index }
    end
  end

  def weekly
    @comments = WikiComment.find :all, :include => :user, :limit => 40, :order => "created_at DESC",
      :conditions => ["created_at < ?", Time.now.beginning_of_week]
    respond_to do |format|
      format.html { render :action => :index }
      format.atom { render :action => :index }
    end
  end

  def show
    wiki_comment = WikiComment.find params[:id]
    @wiki_page = wiki_comment.wiki_page
    if @wiki_page
      redirect_to @wiki_page
    else
      redirect_to wiki_comments_path
    end
  end

  def create
    wiki_comment = WikiComment.new params[:wiki_comment]
    wiki_comment.user = current_user
    if wiki_comment.save
      @wiki_page = wiki_comment.wiki_page
      respond_to do |format|
        format.html do
          flash[:notice] = "Comment posted."
          redirect_to @wiki_page
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
          redirect_to @wiki_page
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
    wiki_comment = WikiComment.find params[:id]
    @wiki_page = wiki_comment.wiki_page
    if wiki_comment.user == current_user or current_user.is_admin?
      wiki_comment.destroy
      flash[:notice] = "Comment deleted."
      redirect_to @wiki_page
    end
  end
end
