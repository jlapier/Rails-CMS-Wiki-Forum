class DashboardsController < ApplicationController
    
  before_filter :require_admin_user
  before_filter :setup_file_share
  
  private
  
  def setup_file_share
    unless defined?(FileShare::FileAttachmentsHelper)
      self.class.helper FileShare::FileAttachmentsHelper
    end
  end
  
  public
  
  def event_calendar
    @past_events = Event.past.order("start_on ASC")
    @future_events = Event.future.order("start_on ASC")
  end
  
  def file_share
    @orphaned_files = FileAttachment.where('attachable_id IS NULL')
    @files = FileAttachment.where('attachable_id IS NOT NULL')
  end
end