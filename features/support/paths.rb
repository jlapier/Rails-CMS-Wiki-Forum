module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
      
    when /the login page/
      '/login'

    when /the event page for "(.*)"/
      event_path(Event.find_by_name($1))
      
    when /the edit link page for "(.*)" "(.*)"/
      event = Event.find_by_name($1)
      link = Link.find_by_name($2)
      p 'event not found' if event.nil?
      p 'link not found' if link.nil?
      edit_event_link_path(event.id, link.id)

    when /the manage events page/
      '/dashboard/event_calendar'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
