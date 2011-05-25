module Blog
  class CommentsController < ApplicationController
    before_filter :require_authorization, :except => [:create]
    private
      def comment
        begin
          @comment ||= Comment.find params[:id]
        rescue ActiveRecord::RecordNotFound => e
          @comment = Comment.new params[:blog_comment]
        end
      end
    
      def require_authorization
        unless has_authorization? action_name.to_sym, comment
          redirect_to blog_dashboard_path, :notice => "Not Found." and return
        end
      end
    public
    def create
      @comment = Comment.new params[:blog_comment]
      @comment.commenter_id = current_user.id if current_user and current_user.logged_in?
      if @comment.save
        redirect_to blog_post_path(@comment.post), :notice => 'Comment saved!'
      else
        @post = @comment.post
        unless @post.published
          redirect_to blog_posts_path, :notice => "Comment cannot be saved." and return
        end
        render 'blog/posts/show'
      end
    end
    def approve
      comment = Comment.find params[:id]
      if comment.approve
        redirect_to blog_dashboard_path, :notice => "Comment approved!"
      else
        redirect_to blog_dashboard_path, :notice => "Error approving comment. Please try again."
      end
    end
    def destroy
      Comment.destroy params[:id]
      redirect_to blog_dashboard_path, :notice => "Comment deleted!"
    end
  end
end