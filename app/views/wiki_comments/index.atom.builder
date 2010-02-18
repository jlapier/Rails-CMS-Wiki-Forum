atom_feed(:url => wiki_wiki_comments_url(@wiki, :format => :atom)) do |feed|
  feed.title("Wiki Chatter - #{@wiki.name}")
  feed.updated(@comments.first ? @comments.first.created_at : Time.now.utc)

  for comment in @comments
    feed.entry(comment, :url => wiki_wiki_comment_url(@wiki, comment)) do |entry|
      entry.title(comment.title)
      entry.content(comment.body, :type => 'html')

      entry.author do |author|
        author.name(comment.user.name)
      end
    end
  end
end
