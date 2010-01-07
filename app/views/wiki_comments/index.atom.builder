atom_feed(:url => formatted_wiki_comments_url(:atom)) do |feed|
  feed.title("Wiki Chatter")
  feed.updated(@comments.first ? @comments.first.created_at : Time.now.utc)

  for comment in @comments
    feed.entry(comment) do |entry|
      entry.title(comment.title)
      entry.content(comment.body, :type => 'html')

      entry.author do |author|
        author.name(comment.user.name)
      end
    end
  end
end
