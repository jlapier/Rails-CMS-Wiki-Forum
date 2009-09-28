class WikiCommentsController < ApplicationController
  def create
    wiki_comment = WikiComment.new params[:wiki_comment]
    wiki_comment.user = current_user
    if wiki_comment.save
      @wiki_page = wiki_comment.wiki_page
      render :update do |page|
        page[:comments].replace_html :partial => '/wiki_pages/comments'
        page[:comments].visual_effect :highlight
      end
    else
      render :update do |page|
        page[:message].update "Unable to save comment. Errors: #{wiki_comment.errors.full_messages.join('; ')}"
      end
    end
  end
end
