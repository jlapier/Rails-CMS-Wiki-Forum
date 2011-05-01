url_to_current = forum_url(@forum, :user_credentials => current_user.single_access_token)
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title(@forum.title)
    xml.description(@forum.description.truncate(20))
    xml.link(url_to_current)
    
    @forum.message_posts.each do |post|
      xml.item do
        xml.title(post.subject)
        xml.description("#{post.body}<p><em>- #{post.user.first_name}</em></p>")
        xml.pubDate(post.created_at.to_s(:rfc822))
        xml.link(url_to_current)
        xml.guid("#{url_to_current}&msg_id=#{post.id}")
      end
    end
  end
end