module Blog::PostsHelper
  def truncated_post_body(post)
    last_p_index = (post.body.index('</p>', 700) || 700)
    post.body.truncate(last_p_index+5, :separator => "\n", :omission => '').html_safe
  end
  def post_tools(post)
    out = ''
    if current_user and current_user.logged_in?
      out += fake_button(link_to_delete_post(post)) + " "
      out += fake_button(link_to_edit_post(post))
    end
    out.html_safe
  end
  def link_to_blog_category_post(post)
    blog_link = "#{link_to('Blog', blog_posts_path)}: "
    category_link = post.category.present? ? "#{link_to(post.category.name, category_path(post.category))}: " : ' '
    "#{blog_link}#{category_link}#{h(post.title)}".html_safe
  end
  def link_to_new_post
    if current_user and current_user.logged_in? # can? :create, Blog::Post.new
      link_to 'New Post', new_blog_post_path
    end
  end
  
  def link_to_delete_post(post)
    if current_user and current_user.logged_in? # can? :delete, post
      link_to 'Delete', blog_post_path(post), :method => :delete, :confirm => "Delete post: #{h(post.title)}?"
    end
  end
  
  def link_to_edit_post(post)
    if current_user and current_user.logged_in? # can? :edit, post
      link_to 'Edit', edit_blog_post_path(post)
    end
  end
  
  def link_to_read_more(post)
    if post.published or (current_user and current_user.logged_in?)
      link_to "Read more...", blog_post_path(post)
    end
  end
end
