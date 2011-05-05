module Blog::PostsHelper
  def link_to_new_post
    if current_user and current_user.logged_in? # can? :create, Blog::Post.new
      link_to 'New Post', new_blog_post_path
    end
  end
  
  def link_to_delete_post(post)
    if current_user and current_user.logged_in? # can? :delete, post
      link_to 'Delete', blog_post_path(post), :method => :delete, :confirm => "Delete post: #{post.title}?"
    end
  end
  
  def link_to_edit_post(post)
    if current_user and current_user.logged_in? # can? :edit, post
      link_to 'Edit', edit_blog_post_path(post)
    end
  end
  
  def link_to_read_more(post)
    if post.published or current_user.logged_in?
      link_to "Read more...", blog_post_path(post)
    end
  end
end
