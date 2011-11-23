# for converting phony content page "user" functions into html

module HtmlGenerator
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def list_categories_to_html(options = {})
      categories = Category.find(:all, :order => options[:order], :limit => options[:limit], :conditions => "parent_id IS NULL", :include => :children)
      out = "<ul>"

      if options[:use_homelink]
        out += homelink
      end

      if categories.empty?
        out += "<li><em>No categories were found</em></li>"
      else
        out += categories.map { |cat|
          if cat.children.empty?
            "<li><a href=\"/categories/#{cat.id}\">#{cat.name}</a></li>"
          else
            "<li>" + 
            main_menu_link("/categories/#{cat.id}", cat.name, "cat_menu_#{cat.id}") +
              "<div class=\"mega_menu cat_menu_#{cat.id} menu_hidable\" style=\"display:none;\">" + 
              "<h4>#{cat.name}</h4>" +
              list_pages_in_category_to_html(:category => cat) +
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
      events = Event.where "start_on > ?", 1.week.ago
      unless options[:other_params].blank?
        events = events.where :event_type => options[:other_params]
      end
      events = events.order("start_on ASC").limit(options[:limit])
      out = "<ul>"

      if events.empty?
        out += "<li><em>No events were found</em></li>"
      else
        events.each do |event|
          date_string = event.start_on.strftime('%B %d')
          if event.end_on and event.end_on.to_date != event.start_on.to_date
            date_string += " - " + (event.start_on.month == event.end_on.month ? event.end_on.strftime('%d') : event.end_on.strftime('%B %d'))
          end
          out += "<li><a href=\"/event_calendar/events/#{event.id}\">#{date_string}: #{event.name}</a></li>"
        end
      end

      out += "</ul>"
      out
    end
    alias_method :listevents_to_html, :list_events_to_html

    def list_pages_in_category_to_html(options = {})
      category = options[:category] || Category.find_by_name(options[:other_params])
      out = "<ul>"

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
            out += category.children.map { |cat| "<li><h5>#{cat.name}</h5></li>" + list_pages_in_category_to_html(:category => cat) }.join("")
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
            header: { left: 'prev,next', right: 'title' },
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
      "<li><a href=\"/\">Home</a></li>"
    end

    def main_menu_link(base_url, link_text, menu_css_class, menu_id = nil)
      <<-END
        <a href="#{base_url}?toggle=#{menu_css_class}&hide=menu_hidable" 
            class="menu_show_hide_link" id="#{menu_id}">#{link_text}</a>
      END
    end

  end
end
