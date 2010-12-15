class EventCalendarSeed < ActiveRecord::Migration
  def self.up
    load File.join(EventCalendar::Engine.root, 'db', 'seeds.rb')
  end
end
