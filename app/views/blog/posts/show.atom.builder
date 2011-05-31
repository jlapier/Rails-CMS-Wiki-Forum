atom_feed(:url => blog_post_url(@post, :atom)) do |feed|
  feed.title("#{blog_title} #{@post.title}") # required
  feed.updated(5.minutes.ago.utc) # required
  
  feed.entry(@post, :url => blog_post_url(@post)) do |entry|
    entry.title(@post.title)
    entry.summary("#{truncated_post_body(post)}", :type => 'html') # required
    entry.content("#{post.body}<p><em>- #{post.author.first_name}</em></p>", :type => 'html')
    entry.author do |author| # required
      author.name(post.author ? post.author.name : 'Anonymous')
    end
  end
  
  @post.comments.each do |comment|
    thread_location = blog_post_url(@post, :anchor => comment.id)
    
    feed.entry(comment, :url => thread_location) do |entry|
      entry.title("#{comment.commenter.name} commented on #{@post.title}") # required
      entry.summary("#{comment.body}", :type => 'html') # required
      entry.content("#{comment.body}<p><em>- #{comment.commenter.name}</em></p>", :type => 'html')

      entry.author do |author| # required
        author.name(comment.commenter ? comment.commenter.name : 'Anonymous')
      end
    end
  end
end
