module EventCalendar
  class Event < ActiveRecord::Base
    set_table_name "event_calendar_events"
    
    attr_accessor :adjust_to_utc
    
    include ActionView::Helpers::TextHelper
    
    include EventInstanceMethods

    has_many :attendees
    has_and_belongs_to_many :links, :join_table => 'event_calendar_events_links'

    validates_presence_of :name, :event_type, :start_on
    
    searchable_by :name, :event_type, :location, :description
    
    acts_as_revisable :revision_class_name => 'EventCalendar::EventRevision', :on_delete => :revise
    
    scope :past, where(sanitize_sql_array(["end_on < '%s'", Date.current]))
    scope :future, where(sanitize_sql_array(["start_on > '%s'", Date.current]))
    scope :current, where(sanitize_sql_array(["end_on >= '%s'", Date.current]))
    scope :between, lambda{ |start_datetime, end_datetime|
      where(["start_on BETWEEN ? AND ? OR end_on BETWEEN ? AND ?",
        start_datetime, end_datetime, start_datetime, end_datetime])
    }
    scope :existing_event_types, select('DISTINCT event_type')
    
    validate :sane_dates
    
    before_validation do
      if one_day? && ((end_on.present? && start_on.present? && end_on <= start_on) ||
                      (end_on.blank? && start_on.present?))
        unless changed_attributes.include?(:revisable_deleted_at)
          self.end_on = start_on + 1.hour
        end
      end
    end
    
    before_save :adjust_to_utc_from_timezone

    private

      def sane_dates
        if start_on and end_on and start_on > end_on
          errors.add :end_on, "cannot be before the start date"
        end
      end
      
      def adjust_to_utc_from_timezone
        return true unless adjust_to_utc
        tz_offset = start_on.in_time_zone(timezone).utc_offset
        self.start_on = self.start_on - tz_offset
        self.end_on = self.end_on - tz_offset
      end
    protected
    public  
      
      def self.event_types
        existing_event_types.map(&:event_type).reject { |ev| ev.blank? }.sort
      end
      
      def participants
        return [] if attendees.count == 0
        attendees.all.collect do |attendee|
          attendee.participant
        end
      end

      def to_s
        "#{name} (#{start_on} #{end_on ? ' - ' + end_on.to_s : ''})"
      end

      def to_ics
        return @ics if @ics
        rical = RiCal.Calendar do |cal|
          cal.event do |event|
            event.summary = name
            event.description = "#{name} (#{event_type}): #{topic}:\n#{description}"
            event.dtstart = start_on
            event.dtend = end_on ? end_on : start_on
            event.location = location
            event.url = "http://#{SiteSetting.read_setting('hostname')}/event_calendar/events/#{id}"
          end
        end
        @ics = rical.to_s
      end
  end
end

# 
#  create_table "event_calendar_events", :force => true do |t|
#    t.string   "name"
#    t.string   "event_type"
#    t.datetime "start_on"
#    t.datetime "end_on"
#    t.text     "location"
#    t.text     "description"
#    t.text     "notes"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#    t.integer  "revisable_original_id"
#    t.integer  "revisable_branched_from_id"
#    t.integer  "revisable_number",           :default => 0
#    t.string   "revisable_name"
#    t.string   "revisable_type"
#    t.datetime "revisable_current_at"
#    t.datetime "revisable_revised_at"
#    t.datetime "revisable_deleted_at"
#    t.boolean  "revisable_is_current",       :default => true
#    t.string   "timezone"
#    t.text     "presenters"
#    t.text     "facilitators"
#    t.string   "topic"
#  end
#
