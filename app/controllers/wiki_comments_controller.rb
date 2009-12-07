class WikiCommentsController < ApplicationController
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
end
