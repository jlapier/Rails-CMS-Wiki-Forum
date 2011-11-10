module EventCalendar
  class LinksController < ApplicationController  
    private
      def event
        @event ||= EventCalendar::Event.find(params[:event_id])
      end
      def link
        @link ||= if params[:id].present?
                    EventCalendar::Link.find(params[:id])
                  else
                    event.links.build(params[:link])
                  end
      end
      def load_resources
        event
        link
      end
      def redirect_to_event
        redirect_to event_calendar_event_path params[:event_id]
      end
      def respond(&block)
        respond_to do |format|
          format.html{ yield }
          format.js
        end
      end
    protected
    public
      def new
        load_resources
      end
      def show
        load_resources
      end
      def edit
        load_resources
      end
      def update
        if link.update_attributes(params[:link])
          flash[:notice] = "Link successfully updated." unless request.xhr?
          event if request.xhr?
          respond{ redirect_to_event }
        else
          event
          respond{ render :edit and return }
        end
      end
      def create
        load_resources
        begin
          event.save!(:without_revision => true)
          flash[:notice] = "Link successfully created." unless request.xhr?
          respond{ redirect_to_event }
        rescue ActiveRecord::RecordInvalid
          respond{ render 'events/show' and return }
        end
      end
      def destroy
        link.destroy
        flash[:notice] = "Link successfully deleted."
        redirect_to_event
      end
  end
end
