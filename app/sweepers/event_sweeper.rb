# TODO: it would be better to load events via javascript than cache them in a page
# otherwise you have to expire cache every day anyway
class EventSweeper < ActionController::Caching::Sweeper
  observe EventCalendar::Event

  def after_create(event)
    expire_content_page_caches
  end

  def after_update(event)
    expire_content_page_caches
  end

  def after_destroy(event)
    expire_content_page_caches
  end

  def expire_content_page_caches
    expire_fragment :controller => '/content_pages', :action => 'home'
    ContentPage.find(:all).each do |content_page|
      expire_fragment :controller => '/content_pages', :action => 'show', :id => content_page
      expire_fragment :controller => '/content_pages', :action => 'show', :id => content_page.id.to_i
    end
  end
end
