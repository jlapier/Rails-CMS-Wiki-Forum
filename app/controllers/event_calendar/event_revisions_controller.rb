module EventCalendar
  class EventRevisionsController < ApplicationController
    
    helper EventsHelper
    
    def index
      if params[:id]
        redirect_to(event_calendar_event_revision_path(params[:id]))
      else
        @deleted_events = EventRevision.deleted
      end
    end
    
    def show
      @event_revision = EventRevision.find params[:id]
    end
    
    
    def restore
      @event_revision = EventRevision.find(params[:id])
      if @event_revision.restore
        flash[:notice] = "Event <em>#{@event_revision.name}</em> restored.".html_safe
        redirect_to(event_calendar_event_path(@event_revision))
      else
        flash[:error] = "There was an error restoring the event."
        redirect_to(event_calendar_event_revisions_path)
      end
    end
  end
end
