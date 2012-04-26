module EventCalendar
  class EventsController < ApplicationController
    
    # before_filter :load_and_authorize_current_user, :except => [:index, :show]
    before_filter :merge_params, :parse_dates_from_params, :only => [:create, :update]
    cache_sweeper :event_sweeper
    
    include EventsHelper
    
    private
      def events_to_json
        return {} unless @events
        json = @events.map do |event|
          {
            :id => event.id,
            :title => event.name,
            :eventType => event.event_type,
            :start => event.start_on.in_time_zone(event.timezone),
            :end => event.end_on.in_time_zone(event.timezone),
            :url => event_calendar_event_path(event),
            :className => event_type_css_class(event.event_type),
            :allDay => !event.one_day?,
            :brief => "<em>#{event.event_type}:</em> #{event.topic}",
            :details => render_to_string(:partial => '/event_calendar/events/details', :object => event)
          }
        end
        json.to_json
      end

      def merge_params
        params[:event].merge!(params[:event_calendar_event]) if params[:event_calendar_event]
      end
      
      def parse_dates_from_params
        params[:event].delete :"start_time(1i)"
        params[:event].delete :"start_time(2i)"
        params[:event].delete :"start_time(3i)"
        params[:event].delete :"end_time(1i)"
        params[:event].delete :"end_time(2i)"
        params[:event].delete :"end_time(3i)"
        start_hour = params[:event].delete :"start_time(4i)"
        start_min = params[:event].delete :"start_time(5i)"
        end_hour = params[:event].delete :"end_time(4i)"
        end_min = params[:event].delete :"end_time(5i)"
        if params[:event][:start_date].present?
          # date is in format: MM/DD/YYYY
          m, d, y = params[:event][:start_date].split("/").map(&:to_i)
          start_date = Date.new y, m, d
          params[:event][:start_on] = Time.utc(start_date.year, start_date.month, start_date.day, start_hour, start_min)
          if params[:event][:end_date].present?
            m, d, y = params[:event][:end_date].split("/").map(&:to_i)
            end_date = Date.new y, m, d
          else
            end_date = start_date
          end
          params[:event][:end_on] = Time.utc(end_date.year, end_date.month, end_date.day, end_hour, end_min)
          params[:event][:start_time] = params[:event][:start_on]
          params[:event][:end_time] = params[:event][:end_on]
        else
          params[:event][:start_time] = ''
          params[:event][:end_time] = ''
        end
      end
    protected
    public
    
    # GET /events
    # GET /events.xml
    def index
      @event_types = EventCalendar::Event.event_types
      if params[:start] && params[:end]
        @events = EventCalendar::Event.between(Time.at(params[:start].to_i), Time.at(params[:end].to_i))
        unless params[:event_type].blank?
          @events = @events.where(:event_type => params[:event_type])
        end
      else
        @past_events = EventCalendar::Event.past.order("start_on ASC")
        @current_events = EventCalendar::Event.current.order("start_on ASC")
        unless params[:event_type].blank?
          @past_events = @past_events.where(:event_type => params[:event_type])
          @current_events = @current_events.where(:event_type => params[:event_type])
        end
      end

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @events }
        format.js { render :json => events_to_json }
      end
    end

    def search
      @events = EventCalendar::Event.search(params[:q], {
        # :narrow_fields; => params[:fields] ? params[:fields].keys : nil
        :page => (params[:page] || 1)
      }) #.paginate :page => params[:page]
      @link = EventCalendar::Link.new
    end
    
    # GET /events/1
    # GET /events/1.xml
    def show
      # @event = EventCalendar::Event.find(params[:id], :include => :file_attachments)
      @event = EventCalendar::Event.find(params[:id])
      @link = @event.links.build
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @event }
        format.ics { render :text => @event.to_ics }
      end
    end

    # GET /events/new
    # GET /events/new.xml
    def new
      @event = EventCalendar::Event.new
      @event.start_time = Time.local(Date.current.year, Date.current.month, Date.current.day, 06, 00)
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @event }
      end
    end

    # GET /events/1/edit
    def edit
      @event = EventCalendar::Event.find(params[:id])
      Time.zone = @event.timezone
    end

    # POST /events
    # POST /events.xml
    def create
      @event = EventCalendar::Event.new(params[:event])
      @event.adjust_to_utc = true
      respond_to do |format|
        if @event.save
          flash[:notice] = 'Event was successfully created.'
          format.html { redirect_to(event_calendar_event_path(@event)) }
          format.xml  { render :xml => @event, :status => :created, :location => @event }
        else
          flash.now[:notice] = @event.errors.full_messages
          format.html { render :action => "new" }
          format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /events/1
    # PUT /events/1.xml
    def update
      @event = EventCalendar::Event.find(params[:id])
      @event.adjust_to_utc = true
      respond_to do |format|
        if @event.update_attributes(params[:event])
          flash[:notice] = 'Event was successfully updated.'
          format.html { redirect_to(@event) }
          format.xml  { head :ok }
        else
          flash.now[:notice] = @event.errors.full_messages
          format.html { render :action => "edit" }
          format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /events/1
    # DELETE /events/1.xml
    def destroy
      @event = EventCalendar::Event.find(params[:id])
      @event.destroy
      
      respond_to do |format|
        format.html { redirect_to(event_calendar_events_path) }
        format.xml  { head :ok }
      end
    end


    def manage_event_types
      @event_types = EventCalendar::Event.event_types
    end

    def update_event_type
      if params[:old].present? and params[:new].present?
        EventCalendar::Event.where(:event_type => params[:old]).update_all(
            :event_type => params[:new])
        flash[:notice] = "Changed #{params[:old]} to #{params[:new]}."
      else
        flash[:warning] = "Missing event type."
      end
      redirect_to :action => :manage_event_types
    end
  end
end
