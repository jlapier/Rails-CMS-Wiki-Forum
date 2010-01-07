class WikiPageObserver < ActiveRecord::Observer
  def after_save(wiki_page)
    WikiComment.create_chatter_about_page wiki_page
  end
end
