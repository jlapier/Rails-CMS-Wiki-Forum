class SiteSettingsController < ApplicationController
  before_filter :require_admin_user

  def index
    @registration_password = SiteSetting.read_setting 'registration password'
    @user_fields = SiteSetting.read_setting 'user fields'
  end

  def update_site_settings
    SiteSetting.write_setting 'site title', params[:site_title]
    SiteSetting.write_setting 'site logo', params[:site_logo]
    SiteSetting.write_setting 'site footer', params[:site_footer]
    SiteSetting.write_setting 'registration password', params[:registration_password]
    SiteSetting.write_setting 'user fields', params[:user_fields].split(',').map(&:strip).map(&:unspace)
    flash[:notice] = "Site configuration updated."
    redirect_to :action => :index
  end
end
