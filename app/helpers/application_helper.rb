# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def top_menu
    @top_menu ? @top_menu.body_for_display : "TODO: create the top menu"
  end

  def side_menu
    @side_menu ? @side_menu.body_for_display : "TODO: create the side menu"
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
  end
end
