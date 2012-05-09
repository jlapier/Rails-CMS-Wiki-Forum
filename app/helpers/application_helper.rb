module ApplicationHelper
  include CkeditorHelper

  def top_menu
    @top_menu ? @top_menu.body_for_display : "TODO: create the top menu"
  end

  def side_menu
    @side_menu ? @side_menu.body_for_display : "TODO: create the side menu"
  end

  def logo_image
    "<img src=\"/images/#{site_logo}\" alt=\"logo\"/>".html_safe
  end

  def search_box(options = {})
    # TODO merge this with methods in in lib/html_generator
    out = <<-END
      <form action="/content_pages/search" method="get" name="site_search_box" id="site_search_box">
        <input type="text" name="q" size="20">
        <input type="submit" value="search">
      </form>
    END
    out.html_safe
  end

  def site_title
    @site_title ||= SiteSetting.read_setting('site title') || "A Site [edit me in site settings]"
  end

  def blog_title
    @blog_title ||= SiteSetting.read_setting('blog title') || "Blog [edit me in site settings]"
  end

  def flash_messages
    out = ""
    if flash[:notice]
      out += "<div class=\"flash_message notice_message\">#{flash[:notice]}</div>"
    end
    if flash[:warning]
      out += "<div class=\"flash_message warning_message\">#{flash[:warning]}</div>"
    end
    if flash[:error]
      out += "<div class=\"flash_message error_message\">#{flash[:error]}</div>"
    end
    out.html_safe
  end

  def page_title
    pre = case action_name
    when "edit" then "Editing "
    when "new"  then "Creating "
    else
      ""
    end
    if @content_page
      "#{pre}#{@content_page.name}"
    elsif @category
      "#{pre}Category: #{@category.name}"
    elsif @wiki_page
      "#{pre}Wiki Page: #{@wiki_page.title}"
    elsif @wiki_tag
      "#{pre}Wiki Tag: #{@wiki_tag.name}"
    elsif @wiki
      "#{pre}Wiki: #{@wiki.name}"
    elsif @message_post
      "#{pre}Message Post: #{@message_post.subject}"
    elsif @forum
      "#{pre}Forum: #{@forum.title}"
    elsif @user
      "#{pre}User: #{@user.login}"
    elsif @user_group
      "#{pre}User Group: #{@user_group.name}"
    elsif @event
      "#{pre}Event: #{@event.name}"
    elsif @post
      "#{blog_title} - #{@post.title}"
    elsif request.path.include? 'blog'
      blog_title
    else
      controller_name.titleize
    end
  end

  def site_logo
    @site_logo ||= SiteSetting.read_setting('site logo') || "GenericLogo.png"
  end

  def site_footer
    @site_footer ||= SiteSetting.read_setting('site footer') ||
      "Content on this site is the copyright of the owners of #{request.host} and is provided as-is without warranty."
    @site_footer.html_safe
  end

  def user_box(my_options={})
    options = { :include_line_breaks => true, :include_blog_link => true,
        :include_events_link => true, :include_wiki_link => true,
        :include_forum_link => true,
        :link_separator => ' | '
      }.merge(my_options)
    out = ""
    other_links = []
    if current_user
      out += "Welcome, #{current_user.first_name}! "
      if(options[:include_line_breaks])
        out += "<br />"
      end
      out += link_to("My Account", account_path) + options[:link_separator].html_safe +
              link_to("Logout", user_session_path, :method => :delete,
                  :confirm => "Are you sure you want to logout?")
      other_links << link_to('Site Admin', admin_site_settings_path) if current_user.is_admin?
      if options[:include_wiki_link] and current_user.has_access_to_any_wikis?
        if current_user.wikis.size == 1
          other_links << link_to('Wiki', current_user.wikis.first)
        else
          other_links << link_to('Wikis', wikis_path)
        end
      end
      if options[:include_forum_link] and current_user.has_access_to_any_forums?
        if current_user.forums.size == 1
          other_links << link_to('Forum', current_user.forums.first)
        else
          other_links << link_to('Forums', forums_path)
        end
      end
    else
      out += link_to("Register", new_account_path) + options[:link_separator].html_safe +
              link_to( "Log In", new_user_session_path)
    end
    if options[:include_blog_link]
      other_links << link_to("Blog", blog_posts_path)
    end
    if options[:include_events_link]
      other_links << link_to_events({:no_wrapper => true}, {:link_text => 'Events'})
    end
    unless other_links.empty?
      if(options[:include_line_breaks])
        out += "<br/>"
      else
        out += options[:link_separator]
      end
      out += other_links.join(options[:link_separator])
    end
    out.html_safe
  end

  def images_list
    Dir[File.join(Rails.root, 'public', 'images', "*.{png,jpg,gif}")].map { |f| File.basename f }.sort
  end

  def theme_layouts_list
    Dir[File.join(Rails.root, 'themes', 'layouts', "*.html.erb")].map { |f| File.basename(f, '.html.erb') }.sort
  end

  def theme_page_layouts_list
    Dir[File.join(Rails.root, 'themes', 'page_layouts', "*.html.erb")].map { |f| File.basename(f, '.html.erb') }.sort
  end

  def theme_skins_list
    Dir[File.join(Rails.root, 'public', 'stylesheets', 'skins', '*.css')].map { |f| File.basename(f, '.css') }.sort
  end

  def theme_colors_list
    Dir[File.join(Rails.root, 'public', 'stylesheets', 'colors', '*.css')].map { |f| File.basename(f, '.css') }.sort
  end

  def is_admin?
    current_user and current_user.is_admin?
  end

  def inner_footer(type)
    out = ""
    ss = SiteSetting.read_setting("inner footer: #{type}")
    unless ss.blank?
      out += "<div class=\"#{type}_footer inner_footer\">"
      out += ss
      out += "</div>"
    end
    out.html_safe
  end

  # TODO: change this to use the zoned plugin or something
	def post_time(time)
		if (Time.now - time) > 2600000
			time.strftime "on %b %d, %Y"
		else
			time_ago_in_words(time) + " ago"
		end
	end
	def uniq_filenames(file_paths_or_names)
	  out = []
	  file_paths_or_names.each do |path_or_name|
	    name = path_or_name.split("/").last
	    out << path_or_name unless out.detect{|pon| pon =~ /#{name}$/}
    end
    out
  end
	def javascripts
	  uniq_filenames(
	    host_javascripts +
      behaviors +
      ['app.js']
	  )
  end
  def host_javascripts
    list = [
      'h5bp-plugins',
      'rails', 'lowpro.jquery.js',
      'jquery.string.1.0-min.js',
      'jquery.clonePosition.js',
      'jquery.qtip-1.0.0-rc3.js',
      'jquery.tablesorter.min.js',
      'jquery-ui-1.8.16.custom.min.js',
      '/ckeditor/ckeditor.js',
      '/ckeditor/adapters/jquery.js',
      'http://www.google.com/jsapi',
#      '/javascripts/plupload/gears_init',
      '/javascripts/plupload/plupload.min.js',
      '/javascripts/plupload/jquery.plupload.queue.js',
      'fullcalendar.js'
    ]
    unless Rails.env == 'production'
      list.unshift("jquery")
    else
      list.unshift("http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js")
# https://ajax.googleapis.com/ajax/libs/jquery/1.6.3/jquery.min.js
    end
  end

  def behaviors
    %w{ checkbox_toggle event_view quick_zoom textarea_expander
        collapsable fs_dynamic_form select_popper
        ec_dynamic_form magic_buttons show_hide_link
    }.map { |b| "/javascripts/behaviors/#{b}.js" }
  end

  def link_to_rss(path)
    link_to ("RSS feed "+image_tag("feed-icon.gif")).html_safe, path
  end
  def nice_date(date)
    return '' if date.nil?
    "#{date.strftime('%A')} #{date.strftime('%B')} #{date.strftime('%d').to_i.ordinalize}, #{date.year}"
  end
  def fake_button(link)
    return '' if link.blank?
    content_tag :span, link, :class => 'fake_button'
  end
  # Graciously appropriated from rails
  # File actionpack/lib/action_view/helpers/prototype_helper.rb, line 595
  # Modified to wrap values in quotes and escape_javascript
  def options_for_javascript(options)
    if options.empty?
      '{}'
    else
      "{#{options.keys.map { |k| "#{k}:'#{escape_javascript(options[k])}'" }.sort.join(', ')}}"
    end
  end
end
