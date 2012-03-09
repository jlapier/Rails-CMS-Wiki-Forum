module EventCalendar
  module EventInstanceMethods
    attr_accessor :start_time, :end_time, :start_date, :end_date
    
    def start_time
      @start_time ||= start_on
    end
    
    def end_time
      @end_time ||= end_on
    end
    
    def start_date
      @start_date ||= start_on.present? ? start_on.to_date : start_on
    end
    
    def end_date
      @end_date ||= end_on.present? ? end_on.to_date : end_on
    end

    def start_year
      start_on.present? ? start_on.in_time_zone(timezone).year : start_on
    end
    
    def start_month
      start_on.present? ? start_on.in_time_zone(timezone).strftime("%B") : start_on
    end
    
    def start_day
      start_on.present? ? start_on.in_time_zone(timezone).day : start_on
    end
    
    def start_hour
      start_on.present? ? start_on.hour : start_on
    end
    
    def start_min
      start_on.present? ? start_on.min : start_on
    end
    
    def end_year
      end_on.present? ? end_on.year : end_on
    end
    
    def end_month
      end_on.present? ? end_on.in_time_zone(timezone).strftime("%B") : end_on
    end
    
    def end_hour
      end_on.present? ? end_on.hour : end_on
    end
    
    def end_min
      end_on.present? ? end_on.min : end_on
    end
    
    def end_day
      end_on.present? ? end_on.in_time_zone(timezone).day : end_on
    end
    
    def one_day?
      return true if start_on.blank? || end_on.blank?
      start_on.day == end_on.day &&
      start_on.month== end_on.month &&
      start_on.year == end_on.year
    end
    
    def date
      one_day? ? one_day_date : multi_day_date
    end
    
    def one_day_date
      start_on.in_time_zone(timezone).strftime('%A, %B %d %Y')
    end
    
    def multi_day_date
      return one_day_date if end_on.blank?
      "#{start_on.in_time_zone(timezone).strftime('%A, %B %d')} - "+
      "#{end_on.in_time_zone(timezone).strftime('%A, %B %d %Y')}"
    end

    def human_display_date
      date_string = start_on.strftime("%B #{ActiveSupport::Inflector.ordinalize(start_on.day)}")
      if end_on and end_on.to_date != start_on.to_date
        date_string += " - " + (start_on.month == end_on.month ? ActiveSupport::Inflector.ordinalize(end_on.day) : 
            end_on.strftime("%B #{ActiveSupport::Inflector.ordinalize(end_on.day)}"))
      end
      
    end
  end
end
