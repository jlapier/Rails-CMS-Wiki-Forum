class SiteSettingsController < ApplicationController
  before_filter :require_admin_user

  def index
    @registration_password = SiteSetting.read_setting 'registration password'
    %w(blog events).each do |c|
      instance_variable_set "@inner_footer_#{c}".to_sym, SiteSetting.read_setting("inner footer: #{c}")
    end
    @user_fields = SiteSetting.read_setting('user fields') || []
  end

  def admin
  end

  def update_site_settings
    SiteSetting.write_setting 'site title', params[:site_title]
    SiteSetting.write_setting 'blog title', params[:blog_title]
    SiteSetting.write_setting 'hostname', params[:hostname]
    SiteSetting.write_setting 'site logo', params[:site_logo]
    SiteSetting.write_setting 'site footer', params[:site_footer]
    SiteSetting.write_setting 'inner footer: blog', params[:inner_footer_blog]
    SiteSetting.write_setting 'inner footer: events', params[:inner_footer_events]
    SiteSetting.write_setting 'registration password', params[:registration_password]
    SiteSetting.write_setting 'user fields', params[:user_fields].split(',').map(&:strip).map(&:unspace)
    flash[:notice] = "Site configuration updated."
    redirect_to :action => :index
  end
end
