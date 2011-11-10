module EventCalendar::EventsHelper
  def event_one_liner(event)
    [
      h(event.name),
      event_abbrev_date(event),
      event_type_label(event.event_type),
      event_details_link(event)
    ].
    join(" ").html_safe
  end
  
  def event_abbrev_date(event)
    if event.one_day?
      "(<em>#{event.start_on.strftime("%a")} #{event.start_day.ordinalize}</em>)".html_safe
    else
      "(<em>#{event.start_on.strftime("%a")} #{event.start_day.ordinalize} - #{event.end_on.strftime("%a")} #{event.end_day.ordinalize}</em>)".html_safe
    end
  end
  
  def event_details_link(event)
    path = "event_calendar_#{event.deleted? ? 'event_revision_path' : 'event_path'}"
    "<span class=\"fake_button\">#{link_to('Details', send(path, event))}</span>".html_safe
  end
  
  def event_type_label(event_type)
    "<span class=\"category_label #{event_type_css_class(event_type)}\">#{h(event_type)}</span>".html_safe
  end
  
  def event_type_css_class(event_type)
    css_class = event_type.parameterize('_').downcase
    h("#{css_class}_event")
  end
  
  def event_type_legend(wrapper_css_class, wrapper_css_style='')
    return '' unless @event_types.any?
    
    content_tag :ul, :class => "#{wrapper_css_class} legend", :style => wrapper_css_style do
      @event_types.map do |event_type|
        css_class = event_type_css_class(event_type)
        content_tag :li, :class => "#{css_class} category_label" do
          link_to h(event_type), event_calendar_events_path(:event_type => event_type)
        end
      end.join("\n").html_safe
    end
  end

  def div_for_record(record, options={}, &block)
    div_for(record, options){ yield }
  end
  def tag_for_record(tag, record, *args, &block)
    content_tag_for(tag, record, *args){ yield }
  end
  
  def link_wrapper(path, wrapper_options={}, link_options={})
    tag       = wrapper_options.delete(:tag) || :p
    link_text = link_options.delete(:link_text) || path
  
    unless wrapper_options.delete(:no_wrapper)
      return content_tag(tag, wrapper_options) do
        link_to(link_text, path, link_options)
      end
    else
      return link_to(link_text, path, link_options)
    end
  end
  
  def open_if_current_month(month, closed_or_open)
    # setting closed_or_open='closed' in args does not seem to work when a
    # nil val is passed as the closed_or_open arg
    closed_or_open = closed_or_open.blank? ? 'closed' : closed_or_open
    Date.current.strftime("%B") == month ? 'open' : closed_or_open
  end
  
  def time_with_zones(time=Time.now)
    out = []
    ActiveSupport::TimeZone.us_zones.map(&:name).each do |us_zone|
      next unless us_zone =~ /Pacific|Mountain|Central|Eastern/
      key = time.in_time_zone(us_zone).strftime("%Z")
      key = timezone_in_words(key.strip)
      # out[key] = time.in_time_zone(us_zone).strftime(format)
      out << [key, time.in_time_zone(us_zone).strftime(TIME_BASE)]
    end
    out.reverse
  end
      
  def timezone_in_words(zone)
    pac_regex = /^P(S|D)T$/
    mnt_regex = /^M(S|D)T$/
    ctr_regex = /^C(S|D)T$/
    est_regex = /^E(S|D)T$/
    case zone
    when pac_regex
      zone.gsub(pac_regex, 'Pacific')
    when mnt_regex
      zone.gsub(mnt_regex, 'Mountain')
    when ctr_regex
      zone.gsub(ctr_regex, 'Central')
    when est_regex
      zone.gsub(est_regex, 'Eastern')
    else
      zone
    end
  end
  
  def event_times(event)
    t = []
    event_times = times_with_zones(event)
    event_times.first.each_with_index do |z_t, i|
      t << "#{z_t.last} - #{event_times.last[i].last} " + content_tag(:em, z_t.first)
    end
    t.join(" / ").html_safe
  end
  
  def times_with_zones(event)
    [
      time_with_zones(event.start_time),
      time_with_zones(event.end_time)
    ]
  end
  
  def hour_options
    [
      ['6 AM','6'],
      ['7 AM','7'],
      ['8 AM','8'],
      ['9 AM','9'],
      ['10 AM','10'],
      ['11 AM','11'],
      ['12 PM','12'],
      ['1 PM','13'],
      ['2 PM','14'],
      ['3 PM','15'],
      ['4 PM','16'],
      ['5 PM','17'],
      ['6 PM','18'],
      ['7 PM','19'],
      ['8 PM','20']
    ]
  end
  
  def minute_options
    ['00', '15', '30', '45']
  end
  
  def link_to_events(wrapper_options={}, link_options={})
    return unless has_authorization?(:read, EventCalendar::Event.new)
    link_wrapper(event_calendar_events_path, wrapper_options, link_options.reverse_merge!({
      :link_text => 'Event Calendar'
    }))
  end
  
  def link_to_event_revisions(wrapper_options={}, link_options={})
    return unless has_authorization?(:read, EventRevision.new)
    link_wrapper(event_calendar_event_revisions_path, {
      :no_wrapper => true
    }.merge!(wrapper_options), {
      :link_text => 'Browse Event Revisions'
    }.merge!(link_options))
  end

  def link_to_new_event(wrapper_options={}, link_options={})
    return unless has_authorization?(:create, EventCalendar::Event.new)
    link_wrapper(new_event_calendar_event_path, {
      :no_wrapper => true
    }.merge!(wrapper_options), {
      :link_text => "Create New Event"
    }.merge!(link_options))
  end

  def link_to_deleted_events(wrapper_options={})
    return unless has_authorization?(:update, EventCalendar::Event.new)
    link_wrapper(event_calendar_event_revisions_path, wrapper_options, {
      :link_text => "Browse Deleted Events (#{EventRevision.deleted.count})"
    })
  end

  def link_to_add_event_attendees(event, wrapper_options={})
    return unless has_authorization?(:add_attendees, event)
    link_wrapper(new_event_attendee_path(event), wrapper_options, {
      :link_text => "Add <em>#{h(event.name)}</em> Attendees".html_safe
    })
  end

  def link_to_edit_event(event, wrapper_options={}, link_options={})
    return unless has_authorization?(:update, event)
    link_wrapper(edit_event_calendar_event_path(event), wrapper_options, {
      :link_text => "Edit <em>#{h(event.name)}</em>".html_safe
    }.merge!(link_options))
  end
  
  def link_to_new_link(event, wrapper_options={}, link_options={})
    return unless has_authorization?(:create, EventCalendar::Link.new)
    link_wrapper(new_event_calendar_event_link_path(event), wrapper_options, {
      :link_text => 'Add a new link to this event',
      :class => 'fake_button'
    }.merge!(link_options))
  end
  
  def link_to_edit_link(event, link, wrapper_options={}, link_options={})
    return unless has_authorization?(:update, link)
    link_wrapper(edit_event_calendar_event_link_path(event, link), {
      :no_wrapper => true
    }.merge!(wrapper_options), {
      :link_text => "update"
    }.merge!(link_options))
  end
  
  def link_to_delete_link(event, link, wrapper_options={}, link_options={})
    return unless has_authorization?(:delete, link)
    link_wrapper(event_calendar_event_link_path(event, link), {
      :no_wrapper => true
    }.merge!(wrapper_options), {
      :link_text => 'delete',
      :confirm => "Are you sure you want to permanently delete the #{link.name} link?",
      :method => "delete"
    }.merge!(link_options))
  end

  def link_to_delete_event(event, wrapper_options={}, link_options={})
    return unless has_authorization?(:delete, event)
    link_wrapper(event_calendar_event_path(event), {
      :highlight => false
    }.merge!(wrapper_options), {
      :link_text => "Delete <em>#{event.name}</em>".html_safe,
      :confirm => "Are you sure you want to permanently delete the #{event.name} #{event.event_type}?",
      :method => "delete"
    }.merge!(link_options))
  end
  
  def links_to_edit_and_delete_event(event, wrapper_options={}, link_options={})
    return unless has_authorization?(:delete, event) || has_authorization?(:update, event)
    link_to_edit_event(event, {
      :no_wrapper => true
    }.merge!(wrapper_options), {
      :link_text => 'update'
    }.merge!(link_options)) + " " +
    link_to_delete_event(event, {
      :no_wrapper => true
    }.merge!(wrapper_options), {
      :link_text => 'delete'
    }.merge!(link_options))
  end

  def form_for_browse_event_revisions(event)
    return unless has_authorization?(:update, event)
    render :partial => 'events/browse_event_revisions', :locals => {
      :event => event
    }
  end

  def render_event_navigation(event=nil)
    render :partial => 'event-calendar-shared/navigation', :locals => {
      :event => event
    }
  end

  def render_event_main_menu
    render :partial => 'event-calendar-shared/main_menu'
  end

  def render_flash
    render :partial => 'event-calendar-shared/flash', :object => flash
  end
  
  def event_calendar_asset_prefix
    'event_calendar/'
  end
  
  def event_calendar_javascript_includes
    list = [
      "#{event_calendar_asset_prefix}jquery.tablesorter.min.js",
      "#{event_calendar_asset_prefix}jquery-ui-1.8.16.custom.min.js",
      "#{event_calendar_asset_prefix}jquery.string.1.0-min.js",
      "#{event_calendar_asset_prefix}jquery.clonePosition.js",
      "#{event_calendar_asset_prefix}lowpro.jquery.js",
      "#{event_calendar_asset_prefix}fullcalendar.js",
      "#{event_calendar_asset_prefix}jquery.qtip-1.0.0-rc3.js",
      "#{event_calendar_asset_prefix}rails",
      "#{event_calendar_asset_prefix}event_calendar_behaviors.js",
      "#{event_calendar_asset_prefix}event_calendar.js"
    ]
    unless Rails.env == 'production'
      list.unshift("#{event_calendar_asset_prefix}jquery")
    else
      list.unshift("http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js")
    end
  end
end
