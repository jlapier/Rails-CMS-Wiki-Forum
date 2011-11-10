RailsCMSWikiForum::Application.config.after_initialize do
  [EventCalendar::Event, Blog::Post].each do |klass|
    klass.send :include, FileContainer
  end
  [EventCalendar::EventsController, Blog::PostsController].each do |klass|
    klass.send :helper, FileAttachmentsHelper
  end
end
