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

  def site_title
    @site_title ||= SiteSetting.read_setting('site title') || "A Site"
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

  def user_box
    #out = "#{pluralize User.logged_in.count, 'user'} currently logged in<br />\n"
    out = ""
    if current_user
      out += "Welcome, #{current_user.first_name}!<br />\n"
      out += link_to("My Account", account_path)  + " | " +
              link_to("Logout", user_session_path, :method => :delete,
                  :confirm => "Are you sure you want to logout?")
      out += "<br/>"
      other_links = []
      other_links << link_to('Site Admin', admin_site_settings_path) if current_user.is_admin?
      if current_user.has_access_to_any_wikis?
        if current_user.wikis.size == 1
          other_links << link_to('Wiki', current_user.wikis.first)
        else
          other_links << link_to('Wikis', wikis_path)
        end
      end
      if current_user.has_access_to_any_forums?
        if current_user.forums.size == 1
          other_links << link_to('Forum', current_user.forums.first)
        else
          other_links << link_to('Forums', forums_path)
        end
      end
      out += other_links.join(' | ')
    else
      out += link_to("Register", new_account_path) + " | " +
              link_to( "Log In", new_user_session_path)
    end
    out += " | "
    out += link_to("Blog", path_to_blog_posts)
    out += " | "
    out += link_to_events({:no_wrapper => true},
                                  {:link_text => 'Events'})
    out.html_safe
  end
  
  def path_to_blog_posts
    blog_posts_path
  end

  def images_list
    Dir[File.join(Rails.root, 'public', 'images', "*.{png,jpg,gif}")].map { |f| File.basename f }.sort
  end

  def theme_layouts_list
    Dir[File.join(Rails.root, 'themes', 'layouts', "*.html.erb")].map { |f| File.basename(f, '.html.erb') }.sort
  end

  def theme_skins_list
    Dir[File.join(Rails.root, 'public', 'stylesheets', 'skins', '*.css')].map { |f| File.basename(f, '.css') }.sort
  end

  def is_admin?
    current_user and current_user.is_admin?
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
	    event_calendar_javascript_includes + 
	    file_share_javascript_includes
	  )
  end
  def host_javascripts
    list = [
      'rails', 'lowpro.jquery.js', 'jquery.string.1.0-min.js',
      'jquery.tablesorter.min.js', 'jquery-ui-1.7.2.custom.min.js',
      'cms_wiki_forum_behaviors', '/ckeditor/ckeditor.js'
    ]
    unless Rails.env == 'production'
      list.unshift("jquery")
    else
      list.unshift("http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js")
    end
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
end
