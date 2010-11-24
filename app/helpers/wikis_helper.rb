module WikisHelper
  def link_to_wiki(wiki, options={})
    return '' unless current_user
    link_body = options.delete(:text) || wiki.name
    link_to_if(can?(:read, wiki), link_body, wiki)
  end
  def link_to_new_wiki
    return '' unless current_user
    if can?(:create, Wiki.new)
      link_to 'New wiki', new_wiki_path
    end
  end
  def link_to_edit_wiki(wiki, options={})
    return '' unless current_user
    
    # todo review cancan implementation
    if can? :update, wiki
      html_body = '<span class="ui-icon ui-icon-document"/>'.html_safe
      text_body = 'Edit Wiki Details'
      link_body = options.delete(:html) ? html_body : text_body
      link_to link_body, edit_wiki_path(wiki), :title => 'click to edit'
    end
  end
  
  def link_to_destroy_wiki(wiki, options={})
    return '' unless current_user
    
    if can? :destroy, wiki
      html_body = '<span class="ui-icon ui-icon-closethick"/>'.html_safe
      text_body = 'delete'
      link_body = options.delete(:html) ? html_body : text_body
      link_to link_body, wiki_path(wiki), {
        :confirm => "Are you sure you want to permanently delete this wiki (#{wiki.name}) " +
          "and it's #{pluralize wiki.wiki_pages.count, 'page'}?",
        :method => :delete,
        :title => "click to delete"
      }
    end
  end

  def link_to_wiki_comments(wiki, options={})
    if can? :read, wiki
      link_to 'chatter', wiki_wiki_comments_path(wiki)
    end
  end
  
  def link_to_wiki_feeds
    content_tag :span, :class => 'feed_links' do
      link_to image_tag('feed-icon.gif') + " all", wiki_wiki_comments_url(@wiki, :format => :atom),
            :title => 'Subscribe to feed for all activity'
      link_to image_tag('feed-icon.gif') + " daily", daily_wiki_wiki_comments_url(@wiki, :format => :atom),
            :title => 'Subscribe to feed for daily digest'
      link_to image_tag('feed-icon.gif') + " weekly", weekly_wiki_wiki_comments_url(@wiki, :format => :atom),
            :title => 'Subscribe to feed for weekly digest'
    end
  end
end
