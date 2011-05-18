RailsCMSWikiForum::Application.config.after_initialize do
  [Event, Blog::Post].each do |klass|
    klass.send :include, FileContainer
  end
  [EventsController, Blog::PostsController].each do |klass|
    klass.send :helper, FileAttachmentsHelper
  end
end
