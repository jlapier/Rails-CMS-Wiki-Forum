class EventCalendarAddPresentersFacilitatorsToEvents < ActiveRecord::Migration
  def self.up
    add_column :event_calendar_events, :presenters, :text
    add_column :event_calendar_events, :facilitators, :text
  end

  def self.down
    remove_column :event_calendar_events, :facilitators
    remove_column :event_calendar_events, :presenters
  end
end
