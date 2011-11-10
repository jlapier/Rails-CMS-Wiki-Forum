module EventCalendar
  class Attendee < ActiveRecord::Base
    set_table_name "event_calendar_attendees"
    
    belongs_to :event
    belongs_to :participant, :polymorphic => true
  end
end
