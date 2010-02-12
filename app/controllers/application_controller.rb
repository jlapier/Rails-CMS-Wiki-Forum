# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable

  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  before_filter :get_menus, :get_layout


  # checks to see if user is a member of a given access group - if not,
  # redirect to account controller
  # for multiple groups, if user is in any of the given groups, they have access
  def require_group_access(group_access_list)
    if require_user
      group_access_list = [group_access_list] unless group_access_list.is_a? Array
      in_a_group = group_access_list.inject(false) { |n,m| n or current_user.has_group_access?(m) }
      unless in_a_group
        store_location
        flash[:notice] = "You must be a member of one of a group with access of: #{group_access_list.join(" or ")}."
        redirect_to account_url
      end
      return in_a_group
    else
      return false
    end
  end

  def require_forum_read_access
    if require_user
      unless current_user.has_read_access_to?(@forum)
        flash[:notice] = "You do not have permission to view that forum."
        redirect_to forums_url
      end
    else
      return false
    end
  end

  def require_forum_write_access
    if require_user
      unless current_user.has_write_access_to?(@forum)
        flash[:notice] = "You do not have post or edit in that forum."
        redirect_to forums_url
      end
    else
      return false
    end
  end

  def require_wiki_read_access
    if require_user
      unless current_user.has_read_access_to?(@wiki)
        flash[:notice] = "You do not have permission to view that wiki."
        redirect_to wikis_url
      end
    else
      return false
    end
  end

  def require_wiki_write_access
    if require_user
      unless current_user.has_write_access_to?(@wiki)
        flash[:notice] = "You do not have permission to edit that wiki."
        redirect_to wikis_url
      end
    else
      return false
    end
  end

  private
    def get_menus
      @side_menu = ContentPage.get_side_menu
      @top_menu = ContentPage.get_top_menu
    end
    
    def get_layout
      @theme_base = SiteSetting.read_or_write_default_setting 'theme base', 'default'
      @theme_layout = SiteSetting.read_or_write_default_setting 'theme layout', 'default'
      @layout_file = File.join(RAILS_ROOT, "/themes/layouts/#{@theme_layout}.html.erb")
      @theme_colors = SiteSetting.read_or_write_default_setting 'theme colors', 'black and white'
      @custom_colors_timestamp = SiteSetting.read_or_write_default_setting 'custom colors timestamp', nil
      @css_override = SiteSetting.read_or_write_default_setting 'css override', nil
      @css_override_timestamp = SiteSetting.read_or_write_default_setting 'css override timestamp', nil
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def require_user
      if current_user
        true
      else
        store_location
        flash[:warning] = "You must be logged in to access this page."
        redirect_to login_path
        false
      end
    end

    def require_admin_user
      unless current_user and current_user.is_admin?
        flash[:error] = "You do not have permission to access that page."
        redirect_to login_path
        return false
      end
    end

    def require_moderator_user
      get_forum
      unless current_user and current_user.is_moderator_for_forum?(@forum)
        flash[:error] = "You do not have permission to access that page."
        redirect_to '/'
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:warning] = "You must be logged out to access this page."
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
