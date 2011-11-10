module EventCalendar
  class EventRevision < ActiveRecord::Base
    set_table_name "event_calendar_events"
    
    acts_as_revision :revisable_class_name => 'EventCalendar::Event'
    
    include DeletableInstanceMethods
    include EventInstanceMethods
    
    scope :deleted, where("revisable_deleted_at IS NOT NULL")
  end
end
