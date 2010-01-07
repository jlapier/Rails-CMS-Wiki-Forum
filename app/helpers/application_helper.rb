# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def top_menu
    @top_menu ? @top_menu.body_for_display : "TODO: create the top menu"
  end

  def side_menu
    @side_menu ? @side_menu.body_for_display : "TODO: create the side menu"
  end

  def logo_image
    image_tag(site_logo)
  end

  def site_title
    @site_title ||= SiteSetting.read_setting('site title') || "A Site"
  end

  def page_title
    pre = case controller.action_name
    when "edit" then "Editing "
    when "new"  then "Creating "
    else
      ""
    end
    if @content_page
      "#{pre} #{@content_page.name}"
    elsif @category
      "#{pre}Category: #{@category.name}"
    elsif @wiki_page
      "#{pre}Wiki Page: #{@wiki_page.title}"
    elsif @wiki_tag
      "#{pre}Wiki Tag: #{@wiki_tag.name}"
    elsif @user
      "#{pre}User: #{@user.login}"
    elsif @user_group
      "#{pre}User Group: #{@user_group.name}"
    else
      controller.controller_name.titleize
    end
  end

  def site_logo
    @site_logo ||= SiteSetting.read_setting('site logo') || "GenericLogo.png"
  end

  def site_footer
    @site_footer ||= SiteSetting.read_setting('site footer') ||
      "Content on this site is the copyright of the owners of #{request.host} and is provided as-is without warranty."
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
      other_links << link_to('Wiki', wiki_pages_path) if current_user.has_access_to?('wiki')
      other_links << link_to('Forums', forums_path) if current_user.has_access_to?('forum')
      out += other_links.join(' | ')
    else
      out += link_to("Register", new_account_path) + " | " +
              link_to( "Log In", new_user_session_path)
    end
    out
  end

  def images_list
    Dir[File.join(RAILS_ROOT, 'public', 'images', "*.{png,jpg,gif}")].map { |f| File.basename f }.sort
  end

  def theme_layouts_list
    Dir[File.join(RAILS_ROOT, 'themes', 'layouts', "*.html.erb")].map { |f| File.basename(f, '.html.erb') }.sort
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
end
