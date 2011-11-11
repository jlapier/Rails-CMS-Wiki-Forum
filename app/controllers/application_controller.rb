class ApplicationController < ActionController::Base

  PUBLIC_RESOURCES = {
    EventCalendar::Event => [:read],
    FileAttachment => [:read, :download],
    Blog::Post => [:read]
  }
  
  # these actions are accessible by users not logged in; used for EventCalendar and FileShare engines
  READ_ACTIONS = %w(index show search download)

  before_filter :protect_event_calendar
  before_filter :protect_file_share
  
  before_filter :setup_file_share if Rails.env == 'development'
  
  protect_from_forgery

#  helper EventCalendar::EventsHelper
  helper FileShare::ApplicationHelper

  helper_method :current_user_session, :current_user, :in_event_calendar?,
                :in_file_share?, :has_authorization?
                
  before_filter :get_menus, :get_layout
  
	private	
	# returns true if resource & action in question are designated as public
	#   see #public_resource?
	# returns false for anonymous requests to non public resources
	# returns result from can? for authenticated requests to non public resources
	def has_authorization?(*args)
    puts "in has auth"
	  return true if public_resource?(*args)
	  return false unless current_user
	  
	  can?(*args)
  end
  
  # returns true if *args identify a public resource; false otherwise
  # public resources are identified in PUBLIC_RESOURCES
  #   PUBLIC_RESOURCES = {
  #    Event => [:read],
  #    FileAttachment => [:read, :download]
  #   }
  
  def public_resource?(*args)
    action, resource = args[0], args[1]
    key = resource.class
    
    PUBLIC_RESOURCES.has_key?(key) && 
      PUBLIC_RESOURCES[key].include?(action)
  end
	
  def in_event_calendar?
    raise
  end
  
  def in_file_share?
    self.class.ancestors.include?(FileShare::ApplicationController)
  end

  def protect_event_calendar
    # allow all users to view events
    if controller_name == "events" and not READ_ACTIONS.include?(action_name)
      return require_admin_user
    end
  end
  
  def protect_file_share
    if in_file_share?
      if controller_name == 'file_attachments' && READ_ACTIONS.include?(action_name)
        # allow anonymous users to view/download files
        return true
      end
      return require_admin_user
    end
  end
  
  def setup_file_share
    EventCalendar::Event.send :include, FileContainer
    EventCalendar::EventsController.send :helper, FileAttachmentsHelper
  end

  def expire_content_page_caches
    expire_fragment :controller => 'content_pages', :action => 'home'
    ContentPage.all.each do |content_page|
      expire_fragment :controller => 'content_pages', :action => 'show', :id => content_page
      expire_fragment :controller => 'content_pages', :action => 'show', :id => content_page.id.to_i
    end
  end

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
  
    def get_menus
      @side_menu = ContentPage.get_side_menu
      @top_menu = ContentPage.get_top_menu
    end
   
    # note: these may get overridden in a controller, for example, content_pages
    def get_layout
      @theme_layout = SiteSetting.read_or_write_default_setting 'theme layout', 'default'
      @layout_file = File.join(Rails.root, "/themes/layouts/#{@theme_layout}.html.erb")
      @css_screen_override = SiteSetting.read_or_write_default_setting 'css screen override', nil
      if @css_screen_override
        @css_screen_override_timestamp = SiteSetting.read_or_write_default_setting 'css screen override timestamp', nil
      end
      @css_override = SiteSetting.read_or_write_default_setting 'css override', nil
      if @css_override
        @css_override_timestamp = SiteSetting.read_or_write_default_setting 'css override timestamp', nil
      else
        @theme_colors = SiteSetting.read_or_write_default_setting 'theme colors', 'black_and_white'
        @theme_skin = SiteSetting.read_or_write_default_setting 'theme skin', 'default'
      end
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
      return false unless require_user
      unless current_user and current_user.is_admin?
        flash[:error] = "You do not have permission to access that page."
        redirect_to account_path
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

    # takes a file upload object and the relative directory to save it to
    # returns the relative location of the uploaded file
    def write_file(uploaded_file, rel_dir)
      file_name = uploaded_file.original_filename
      actual_dir = File.join(Rails.root, 'public', rel_dir)
      FileUtils.mkdir_p actual_dir
      File.open(File.join(actual_dir, file_name), 'wb') do |f|
        f.write(uploaded_file.read)
      end
    end
    
    def save_asset_for(obj, asset)
      rel_dir = asset_path_for(obj, :relative)
      write_file(asset, rel_dir)
      rel_dir
    end
    
    def rm_asset_for(obj, asset)
      file = File.join asset_path_for(obj), asset
      File.exists?(file) and File.delete(file)
    end
    
    def record_editing_user_for(obj)
      unless obj.editing_user
        obj.update_attributes :editing_user => current_user, :started_editing_at => Time.now
      end
    end
    
    def remove_editing_user_record_for(obj)
      if obj.editing_user == current_user
        obj.update_attributes :editing_user => nil, :started_editing_at => nil
      end
    end

    def asset_path_prefix_for(obj)
      case obj.class.to_s
      when 'WikiPage'
        'wiki_page'
      when 'Blog::Post'
        'blog_post'
      else
        obj.to_english
      end
    end

    def asset_path_for(obj, path_type=:absolute)
      if path_type == :absolute
        return File.join Rails.root, 'public', asset_path_for(obj, :relative)
      else path_type == :relative
        prefix = asset_path_prefix_for(obj)
        return File.join "#{prefix}_assets", "#{prefix}_#{obj.id}"
      end
    end

    def list_assets_for(obj)
      Dir[File.join(asset_path_for(obj), '*')].map { |f| File.basename(f) }
    end
end
