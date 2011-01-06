class EventCalendarChangeStartOnEndOnToTimestamp < ActiveRecord::Migration
  def self.up
    change_column :event_calendar_events, :start_on, :datetime
    change_column :event_calendar_events, :end_on, :datetime
  end

  def self.down
    change_column :event_calendar_events, :start_on, :date
    change_column :event_calendar_events, :end_on, :date
  end
end
