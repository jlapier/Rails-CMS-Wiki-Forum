class ThemesController < ApplicationController
  before_filter :require_admin_user, :except => [ :colors, :css, :images ]
  
  caches_page :colors
  def index
    @custom_colors = SiteSetting.read_setting('custom colors') || []
  end

  def colors
    @colors = case @theme_colors
    when 'default' then COLOR_SCHEMES['black and white']
    when 'custom' then SiteSetting.read_setting('custom colors')
    else
      COLOR_SCHEMES[@theme_colors]
    end
  end

  def css_editor
    @css = SiteSetting.read_setting('css override') ||
      File.read( File.join(RAILS_ROOT, 'public', 'stylesheets', 'main_elements.css') )
  end

  def update_css
    SiteSetting.write_setting('css override', params[:css])
    SiteSetting.write_setting('css override timestamp', Time.now.to_i)
    flash[:notice] = "CSS override updated."
    redirect_to :action => :css_editor
  end

  def css
  end

  def images
  end

  def update_theme_settings
    expire_page :action => :colors
    
    if params[:theme_colors] == 'custom' and @theme_colors != 'custom'
      SiteSetting.write_setting 'custom colors', COLOR_SCHEMES[@theme_colors]
    elsif params[:custom_colors]
      SiteSetting.write_setting 'custom colors', params[:custom_colors].split("\n").map(&:strip)
    else
      SiteSetting.write_setting 'custom colors', nil
    end
    
    SiteSetting.write_setting 'theme layout', params[:theme_layout]
    SiteSetting.write_setting 'theme colors', params[:theme_colors]
    flash[:notice] = "Theme configuration updated."
    redirect_to :action => :index
  end
end
