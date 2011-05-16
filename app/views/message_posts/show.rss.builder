url_to_current = forum_message_post_url(@forum, @message_post, :user_credentials => current_user.single_access_token)
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title("#{@forum.title}: #{@message_post.subject}")
    xml.description(@message_post.subject)
    xml.link(url_to_current)
    
    xml.item do
      xml.title(@message_post.subject)
      xml.description("#{@message_post.body}<p><em>- #{@message_post.user.first_name}</em></p>")
      xml.pubDate(@message_post.created_at.to_s(:rfc822))
      xml.link(url_to_current)
      xml.guid("#{url_to_current}&msg_id=#{@message_post.id}")
    end
    
    @child_posts.each do |post|
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