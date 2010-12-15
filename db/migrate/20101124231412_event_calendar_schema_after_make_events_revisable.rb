class EventCalendarSchemaAfterMakeEventsRevisable < ActiveRecord::Migration
  def self.up
    create_table "event_calendar_attendees", :force => true do |t|
      t.integer  "event_id"
      t.integer  "participant_id"
      t.string   "participant_type"
      t.string   "role"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "event_calendar_events", :force => true do |t|
      t.string   "name"
      t.string   "event_type"
      t.date     "start_on"
      t.date     "end_on"
      t.text     "location"
      t.text     "description"
      t.text     "notes"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "revisable_original_id"
      t.integer  "revisable_branched_from_id"
      t.integer  "revisable_number",           :default => 0
      t.string   "revisable_name"
      t.string   "revisable_type"
      t.datetime "revisable_current_at"
      t.datetime "revisable_revised_at"
      t.datetime "revisable_deleted_at"
      t.boolean  "revisable_is_current",       :default => true
    end
  end
end
