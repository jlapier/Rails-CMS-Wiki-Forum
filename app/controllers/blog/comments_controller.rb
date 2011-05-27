module Blog
  class CommentsController < ApplicationController
    before_filter :require_authorization, :except => [:create]
    include BlogHelper
  private    
    def require_authorization
      unless has_authorization? action_name.to_sym, comment
        redirect_to blog_posts_path, :notice => "Not Found." and return
      end
    end
  public
    def create
      comment.request_approval current_user
      if comment.save
        redirect_to blog_post_path(comment.post_id), :notice => 'Comment saved!'
      else
        @post = comment.post
        unless @post.published
          redirect_to blog_posts_path, :notice => "Comment cannot be saved." and return
        end
        comments # load @comments
        render 'blog/posts/show'
      end
    end
    def approve
      comment.approve
      if comment.save
        redirect_to blog_dashboard_path, :notice => "Comment approved!"
      else
        redirect_to blog_dashboard_path, :notice => "Error approving comment. Please try again."
      end
    end
    def destroy
      comment.destroy
      redirect_to blog_dashboard_path, :notice => "Comment deleted!"
    end
  end
end