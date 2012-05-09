# for converting phony content page "user" functions into html

module HtmlGenerator
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def list_categories_to_html(options = {})
      categories = Category.find(:all, :order => options[:order], :limit => options[:limit], :conditions => "parent_id IS NULL", :include => :children)
      out = "<ul>"

      out += homelink   if options[:use_homelink]
      out += eventslink if options[:use_eventslink]
      out += bloglink   if options[:use_bloglink]

      if categories.empty?
        out += "<li><em>No categories were found</em></li>"
      else
        out += categories.map { |cat|
          if cat.children.empty? and cat.content_pages.count == 0
            "<li class=\"category_#{cat.id}\"><a href=\"/categories/#{cat.id}\">#{cat.name}</a></li>"
          else
            "<li class=\"category_#{cat.id}\">" +
              main_menu_link("/categories/#{cat.id}", cat.name, "cat_menu_#{cat.id}") +
              "<div class=\"mega_menu cat_menu_#{cat.id} menu_hidable\" style=\"display:none;\">" +
                (cat.content_pages.count == 0 ? '' : "<h4>#{cat.name}</h4>") +
                list_pages_in_category_to_html(:category => cat, :cascade => options[:cascade]) +
              "</div>" +
            "</li>"
          end
        }.join("")
      end

      out += "</ul>"
      out
    end
    alias_method :listcategories_to_html, :list_categories_to_html

    def list_events_to_html(options = {})
      # TODO: make this an option so if you want it to go back more than a day, you can
      events = EventCalendar::Event.where "start_on > ?", 1.day.ago
      unless options[:other_params].blank?
        events = events.where :event_type => options[:other_params]
      end
      events = events.order("start_on ASC").limit(options[:limit])
      out = '<ul class="event_list_in_page">'

      if events.empty?
        out += "<li><em>No events were found</em></li>"
      else
        events.each do |event|
          out += "<li><a href=\"/event_calendar/events/#{event.id}\">#{event.human_display_date}: #{event.name}</a></li>"
        end
      end

      out += "</ul>"
      out
    end
    alias_method :listevents_to_html, :list_events_to_html

    def list_pages_in_category_to_html(options = {})
      category = options[:category] || Category.find_by_name(options[:other_params])
      out = ""

      out += "<ul>"

      if options[:use_homelink]
        out += homelink
      end

      if category
        pages = category.content_pages.find(:all,
          :conditions => ['is_preview_only = ? AND (publish_on IS NULL OR publish_on <= ?)', false, Date.today],
          :order => options[:order], :limit => options[:limit])
        if pages.empty? and category.children.empty?
          out += "<li><em>No pages were found in the category: #{category.name}</em></li>"
        else
          out += pages.map { |page|
            "<li><a href=\"/content_pages/#{page.id}\">#{page.name}</a></li>"
          }.join("")
          unless category.children.empty?
            category.children.each do |cat|
              out += "<li><h5><a class=\"menu_show_hide_link\" href=\"/categories/#{cat.id}?toggle=cat_menu_#{cat.id}&hide=inner_menu\">#{cat.name}</a></h5></li>"
              out += "<div style=\"display:none;\" class=\"cat_menu_#{cat.id} inner_menu\">" if options[:cascade]
              out += list_pages_in_category_to_html(:category => cat, :cascade => options[:cascade])
              out += "</div>" if options[:cascade]
            end
          end
        end
      else
        out += "<li><em>No category found: #{options[:other_params] || options[:category]}</em></li>"
      end

      out += "</ul>"
      out
    end
    alias_method :listpagesincategory_to_html, :list_pages_in_category_to_html

    def tree_categories_to_html(options = {})
      categories = \
        if options[:other_params].blank?
          Category.find(:all, :include => :content_pages,
            :order => options[:order], :limit => options[:limit])
        else
          Category.find(:all, :conditions => ["name in (?)", options[:other_params]],
            :include => :content_pages,
            :order => options[:order], :limit => options[:limit])
        end

      out = "<ul>"

      if options[:use_homelink]
        out += homelink
      end

      if categories.empty?
        out += "<li><em>No categories were found</em></li>"
      else
        out += categories.map { |cat|
          "<li><a href=\"/categories/#{cat.id}\">#{cat.name}</a>" +
            "<ul>" +
            cat.content_pages.map { |page|
              "<li><a href=\"/content_pages/#{page.id}\">#{page.name}</a></li>"
            }.join("") +
          "</ul></li>"
        }.join("")
      end

      out += "</ul>"
      out
    end
    alias_method :treecategories_to_html, :tree_categories_to_html

    def link_page_to_html(options={})
      page_name = options[:other_params]
      page = ContentPage.find_by_name page_name

      if page
        "<a href=\"/content_pages/#{page.id}\">#{page.name}</a>"
      else
        "<em>No page found named: #{page_name}</em>"
      end
    end
    alias_method :linkpage_to_html, :link_page_to_html

    def link_category_to_html(options={})
      category_name = options[:other_params]
      category = Category.find_by_name category_name

      if category
        "<a href=\"/categories/#{category.id}\">#{category.name}</a>"
      else
        "<em>No category found named: #{category_name}</em>"
      end
    end
    alias_method :linkcategory_to_html, :link_category_to_html

    # show recent messages in all forums the user has access to
    def all_recent_message_posts_to_html(options = {})
      # TODO: maybe set this up to poll every few minutes
      id = options[:id] ||= "all_recent_messages"

      <<-END
        <div id="#{id}" class="recent_messages_box">
          <em>please log in to view recent messages from the forums</em>
        </div>
        <script type="text/javascript">
          $(document).ready(function() {
            CMSApp.getRecentMessagesFromAll( $('##{id}') );
          });
        </script>
      END
    end
    alias_method :allrecentmessageposts_to_html, :all_recent_message_posts_to_html

    # show just the recent threads of one forum
    def recent_message_posts_to_html(options = {})
      # TODO: maybe set this up to poll every few minutes
      id = options[:id] ||= "recent_messages"
      forum_title = options[:other_params]
      forum = Forum.find_by_title(forum_title)

      <<-END
        <div id="#{id}" class="recent_messages_box">
          <em>please log in to view recent messages from the forums</em>
        </div>
        <script type="text/javascript">
          $(document).ready(function() {
            CMSApp.getRecentMessages( $('##{id}'), #{forum.id} );
          });
        </script>
      END
    end
    alias_method :recentmessageposts_to_html, :recent_message_posts_to_html

    def recent_wiki_comments_to_html(options = {})
      # TODO: maybe set this up to poll every few minutes
      id = options[:id] ||= "recent_wiki_comments"

      <<-END
        <div id="#{id}" class="recent_messages_box">
          <em>please log in to view recent wiki activity</em>
        </div>
        <script type="text/javascript">
          $(document).ready(function() {
            CMSApp.getRecentWikiComments( $('##{id}') );
          });
        </script>
      END
    end
    alias_method :recentwikicomments_to_html, :recent_wiki_comments_to_html


    def search_box_to_html(options = {})
      # TODO make an option to include category dropdown - :with_category_list
      <<-END
        <form action="/content_pages/search" method="get" name="site_search_box" id="site_search_box">
          <input type="text" name="q" size="20">
          <input type="submit" value="search">
        </form>
      END
    end
    alias_method :searchbox_to_html, :search_box_to_html

    def mini_calendar_to_html(options={})
      #TODO - make options for changing id of calendar element
      <<-END
        <link href="/stylesheets/minical.css" media="screen, projection" rel="stylesheet" type="text/css" />

        <div id="minicalendar" class="calendars"></div>

        <script type="text/javascript">
        $(document).ready(function() {
          $('#minicalendar').fullCalendar({
            header: { left: 'prev', right: 'next', center: 'title' },
            editable: false,
            events: '/event_calendar/events',
            eventMouseover: function(event, jsEvent, view) {
                $(jsEvent.target).attr('title', event.title);
              }
          });
        });
        </script>
      END
    end
    alias_method :minicalendar_to_html, :mini_calendar_to_html

    def calendar_to_html(options={})
      options[:height] ||= 500
      #TODO - make options for changing id of calendar element
      <<-END
        <div id="calendar" class="calendars"></div>

        <div style="clear:both"></div>

        <div id="event_quick_description" style="display:none"></div>

        <script type="text/javascript">
        $(document).ready(function() {
          $('#calendar').fullCalendar({
            header: { left: 'prev,next today', center: 'title', right: 'month,agendaWeek,agendaDay' },
            editable: false,
            events: '/event_calendar/events',
            height: #{options[:height]},
            aspectRatio: 1,
            eventMouseover: updateEventDescription
          });
        });
        </script>
      END
    end

    private
    def homelink
      "<li class=\"homelink\"><a href=\"/\">Home</a></li>"
    end

    def eventslink
      "<li class=\"eventslin class=\"bloglink\"k\"><a href=\"/event_calendar/events\">Events Calendar</a></li>"
    end

    def bloglink
      "<li class=\"bloglink\"><a href=\"/blog\">#{SiteSetting.read_or_write_default_setting('blog title','Blog')}</a></li>"
    end

    def main_menu_link(base_url, link_text, menu_css_class, menu_id = nil)
      "<a href=\"#{base_url}?toggle=#{menu_css_class}&hide=menu_hidable\" " +
        "class=\"menu_show_hide_link\" id=\"#{menu_id}\">#{link_text}</a>"
    end

  end
end
