module Blog::CommentsHelper
  def link_to_approve_blog_comment(comment)
    return unless has_authorization?(:approve, comment)
    fake_button(link_to("Approve", approve_blog_comment_path(comment), {
      :method => :post
    }))
  end 
  
  def link_to_delete_blog_comment(comment)
    return unless has_authorization?(:delete, comment)
    fake_button(link_to("Delete", blog_comment_path(comment), {
      :method => :delete,
      :confirm => "Delete this comment?"
    }))
  end
end