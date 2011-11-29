class AddTopicToEvents < ActiveRecord::Migration
  def self.up
    add_column :event_calendar_events, :topic, :string
  end

  def self.down
    remove_column :event_calendar_events, :topic
  end
end
