class SiteSettingsController < ApplicationController
  before_filter :require_admin_user

  def update_site_settings
    SiteSetting.write_setting 'site title', params[:site_title]
    SiteSetting.write_setting 'site logo', params[:site_logo]
    SiteSetting.write_setting 'site footer', params[:site_footer]
    flash[:notice] = "Site configuration updated."
    redirect_to :action => :index
  end
end
