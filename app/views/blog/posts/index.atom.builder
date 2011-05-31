atom_feed(:url => blog_posts_url(:atom)) do |feed|
  feed.title("#{site_title} #{blog_title}") unless params[:author_id] # required
  feed.title("#{site_title} #{blog_title} posts by #{@posts.first.author.first_name}") if params[:author_id]
  
  feed.updated(5.minutes.ago.utc) # required

  @posts.each do |post|
    thread_location = blog_post_url(post)
    
    feed.entry(post, :url => thread_location) do |entry|
      entry.title(strip_tags(post.title)) # required
      entry.summary("#{truncated_post_body(post)}", :type => 'html') # required
      entry.content("#{post.body}<p><em>- #{post.author.first_name}</em></p>", :type => 'html')

      entry.author do |author| # required
        author.name(post.author ? post.author.name : 'Anonymous')
      end
    end
  end
end
