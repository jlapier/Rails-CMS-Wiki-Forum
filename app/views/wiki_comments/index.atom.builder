atom_feed(:url => wiki_wiki_comments_url(@wiki, :format => :atom)) do |feed|
  feed.title("Wiki Chatter - #{@wiki.name}")
  feed.updated(@comments.first ? @comments.first.created_at : Time.now.utc)

  for comment in @comments
    url = comment.new_record? ? wiki_wiki_comments_url(@wiki) : wiki_wiki_comment_url(@wiki, comment)
    feed.entry(comment, :url => url) do |entry|
      entry.title(strip_tags(comment.title))
      entry.content(comment.to_html, :type => 'html')

      entry.author do |author|
        author.name(comment.user ? comment.user.name : 'someone')
      end
    end
  end
end
