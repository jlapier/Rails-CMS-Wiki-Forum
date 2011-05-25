class DashboardsController < ApplicationController
    
  before_filter :require_admin_user
  helper EventsHelper
  
  private
  
  public
  
  def event_calendar
    @past_events    = Event.past.order("start_on ASC")
    @current_events = Event.current.order("start_on ASC")
  end
  
  def blog
    @published_posts    = Blog::Post.published
    @draft_posts        = Blog::Post.draft
    @approved_comments = Blog::Comment.approved
    @pending_comments   = Blog::Comment.pending
  end
end
