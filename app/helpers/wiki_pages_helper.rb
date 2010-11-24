module WikiPagesHelper
  def link_to_new_wiki_page(wiki, options={})
    if can? :create, WikiPage.new, wiki
      text = options.delete(:text) || "create new page"
      link = link_to(text, new_wiki_wiki_page_path(wiki))
      link = "<p>[#{link}]</p>".html_safe if options.delete :pb
      link
    end
  end
  
  def link_to_edit_wiki_page(wiki_page, options={})
    if can? :update, wiki_page
      link_to 'edit', edit_wiki_wiki_page_path(wiki_page.wiki, wiki_page)
    end
  end
  
  def link_to_delete_wiki_page(wiki_page, options={})
    if can? :delete, wiki_page
      link_to 'delete', wiki_wiki_page_path(wiki_page.wiki, wiki_page), {
        :confirm => "Are you really sure you want to delete this wiki page?",
        :method => :delete
      }
    end
  end
  
  def link_to_wiki_page_history(wiki_page, options={})
    if can? :read, wiki_page
      link_to 'history', history_wiki_wiki_page_path(wiki_page.wiki, wiki_page)
    end
  end
end
