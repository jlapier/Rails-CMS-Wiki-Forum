module BlogHelper
  
  def post
    @post ||= if params[:id]
        Blog::Post.find params[:id]
      else
        Blog::Post.new params[:blog_post]
      end
  end
  
  def comment
    @comment ||= if params[:id]
      Blog::Comment.find params[:id]
    else
      Blog::Comment.new params[:blog_comment]
    end
  end
    
  def comments
    @comments ||= if current_user and current_user.logged_in? and current_user.is_admin?
        post.comments
      else
        post.comments.approved
      end
  end
end