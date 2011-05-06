atom_feed(:url => feed_forum_url(@forum, current_user.single_access_token, :atom)) do |feed|
  feed.title(@forum.title) # required
  feed.updated(5.minutes.ago.utc) # required
  # feed.author # required unless each entry contains an author

  @forum.message_posts.each do |message_post|
    thread_location = forum_message_post_url(@forum, message_post, :user_credentials => current_user.single_access_token)
    feed.entry(message_post, :url => thread_location) do |entry|
      entry.title(strip_tags(message_post.subject)) # required
      entry.summary("#{message_post.body.truncate(75)}", :type => 'html') # required
      entry.content("#{message_post.body}<p><em>- #{message_post.user.first_name}</em></p>", :type => 'html')

      entry.author do |author| # required
        author.name(message_post.user ? message_post.user.name : 'someone')
      end
    end
  end
end
