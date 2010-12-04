class DashboardsController < ApplicationController
  
  if defined?(FileShare::FileAttachmentsHelper)
    helper FileShare::FileAttachmentsHelper
  end
  
  before_filter :require_admin_user
  
  def event_calendar
    @past_events = Event.past.order("start_on ASC")
    @future_events = Event.future.order("start_on ASC")
  end
  
  def file_share
    @orphaned_files = FileAttachment.where('attachable_id IS NULL')
    @files = FileAttachment.where('attachable_id IS NOT NULL')
  end
end