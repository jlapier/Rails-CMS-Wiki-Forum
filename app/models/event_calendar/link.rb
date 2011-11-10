module EventCalendar
  class Link < ActiveRecord::Base
    set_table_name 'event_calendar_links'
    
    has_and_belongs_to_many :events, :join_table => 'event_calendar_events_links'
    
    before_validation :detect_or_prepend_default_protocol
    
    validates_presence_of :name, :url
    
    private
      def detect_or_prepend_default_protocol
        self.url = 'http://'+url if scheme.blank? and url.present?
      end
    protected
    public
      def scheme
        url.present? ? URI.parse(url).scheme : ''
      end
  end
end
