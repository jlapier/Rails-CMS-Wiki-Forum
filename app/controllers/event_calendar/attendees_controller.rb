module EventCalendar
  class AttendeesController < ApplicationController
    
    before_filter :load_event
    
    rescue_from ActiveRecord::RecordInvalid, :with => :invalid_record

    include ActionView::Helpers::TextHelper # for pluralize in #create
    
    private
      def invalid_record(e)
        if action_name == 'create'
          flash.now[:notice] = "A processing error occurred while attempting "+
                               "to create the selected attendees."
                               
          
          @events = EventCalendar::Event.all
          @participants = Participant.types.collect do |type|
            type.send(:find, :all)
          end.flatten
          render :new
        end
      end
      def load_all_participants
        @participants = Participant.types.collect do |type|
            type.send(:find, :all)
        end.flatten
      end
      def load_event
        if params[:event_id]
          @event = EventCalendar::Event.includes(:attendees).find(params[:event_id])
        else
          redirect_to(events_path, {
            :notice => "Which event does the new attendee apply to?"
          })
        end
      end
    protected
    public
      def index
        # load_event in before_filter
      end
      def new
        @attendee = Attendee.new
        @events = EventCalendar::Event.includes(:attendees).all
        load_all_participants
      end
      def create
        attendees = Participator.create!(params[:attendee])
        redirect_to(events_path, {
          :notice => "Created #{pluralize(attendees.count, 'Attendee')}!"
        })
      end
  end
end
