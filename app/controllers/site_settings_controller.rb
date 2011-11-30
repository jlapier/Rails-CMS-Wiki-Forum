class SiteSettingsController < ApplicationController
  before_filter :require_admin_user

  def index
    @error_page_id = SiteSetting.read_setting 'error page id'
    @registration_password = SiteSetting.read_setting 'registration password'
    %w(blog events).each do |c|
      instance_variable_set "@inner_footer_#{c}".to_sym, SiteSetting.read_setting("inner footer: #{c}")
    end
    @user_fields = SiteSetting.read_setting('user fields') || []
  end

  def admin
  end

  def update_site_settings
    use_params = params.reject { |k,v| v.blank? }
    SiteSetting.write_setting 'site title', use_params[:site_title]
    SiteSetting.write_setting 'blog title', use_params[:blog_title]
    SiteSetting.write_setting 'hostname', use_params[:hostname]
    SiteSetting.write_setting 'site logo', use_params[:site_logo]
    SiteSetting.write_setting 'site footer', use_params[:site_footer]
    SiteSetting.write_setting 'inner footer: blog', use_params[:inner_footer_blog]
    SiteSetting.write_setting 'inner footer: events', use_params[:inner_footer_events]
    SiteSetting.write_setting 'registration password', use_params[:registration_password]
    SiteSetting.write_setting 'error page id', use_params[:error_page_id]
    if use_params[:user_fields]
      SiteSetting.write_setting 'user fields', 
        use_params[:user_fields].split(',').map(&:strip).map(&:unspace)
    end
    flash[:notice] = "Site configuration updated."
    redirect_to :action => :index
  end
end
