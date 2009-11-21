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

  def site_logo
    @site_logo ||= SiteSetting.read_setting('site logo') || "GenericLogo.png"
  end

  def site_footer
    @site_footer ||= SiteSetting.read_setting('site footer') ||
      "Content on this site is the copyright of the owners of #{request.host} and is provided as-is without warranty."
  end

  def user_box
    out = "#{pluralize User.logged_in.count, 'user'} currently logged in<br />\n"

    if current_user
      out += link_to("My Account", account_path)  + " | " +
              link_to("Logout", user_session_path, :method => :delete,
                  :confirm => "Are you sure you want to logout?")
    else
      out += link_to("Register", new_account_path) + " | " +
              link_to( "Log In", new_user_session_path)
    end
    if current_user.is_admin?
      out += " | " + link_to('Site Admin', admin_site_settings_path)
    end
    out
  end

  def images_list
    Dir[File.join(RAILS_ROOT, 'public', 'images', "*.{png,jpg,gif}")].map { |f| File.basename f }.sort
  end

  def theme_layouts_list
    Dir[File.join(RAILS_ROOT, 'themes', 'layouts', "*.html.erb")].map { |f| File.basename(f, '.html.erb') }.sort
  end
end
