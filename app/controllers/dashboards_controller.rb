class DashboardsController < ApplicationController
  before_filter :require_admin_user
  
  def event_calendar
    @events = Event.order("start_on DESC")
  end
end