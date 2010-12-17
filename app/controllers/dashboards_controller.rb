class DashboardsController < ApplicationController
    
  before_filter :require_admin_user
  
  private
  
  public
  
  def event_calendar
    @past_events = Event.past.order("start_on ASC")
    @future_events = Event.future.order("start_on ASC")
    @current_events = Event.current.order("start_on ASC")
  end
end