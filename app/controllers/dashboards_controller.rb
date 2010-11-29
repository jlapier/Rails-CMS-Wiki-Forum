class DashboardsController < ApplicationController
  before_filter :require_admin_user
  
  def event_calendar
    @past_events = Event.past.order("start_on ASC")
    @future_events = Event.future.order("start_on ASC")
  end
end