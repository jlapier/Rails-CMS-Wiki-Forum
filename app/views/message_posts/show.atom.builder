atom_feed(:url => forum_message_post_url(@forum, @message_post, :user_credentials => current_user.single_access_token, :format => :atom)) do |feed|
  feed.title("#{@forum.title}: #{@message_post.subject}") # required
  feed.updated(Time.now.utc) # required
  # feed.author # required unless each entry contains an author
  
  feed.entry(@message_post, :url => forum_message_post_url(@forum, @message_post, :user_credentials => current_user.single_access_token)) do |entry|
    entry.title(@message_post.subject)
    entry.content("#{@message_post.body}<p><em>- #{@message_post.user.first_name}</em></p>", :type => 'html')
    entry.author do |author|
      author.name(@message_post.user ? @message_post.user.name : 'anonymous')
    end
  end
  
  @child_posts.each do |post|
    feed.entry(post, :url => forum_message_post_url(@forum, @message_post, :user_credentials => current_user.single_access_token)) do |entry|
      entry.title(post.subject)
      entry.content("#{post.body}<p><em>- #{post.user.first_name}</em></p>", :type => 'html')
      entry.author do |author|
        author.name(post.user ? post.user.name : 'anonymous')
      end
    end
  end
end
