class EventCalendarAddTimezoneToEvents < ActiveRecord::Migration
  def self.up
    add_column :event_calendar_events, :timezone, :string
  end

  def self.down
    remove_column :event_calendar_events, :timezone
  end
end
