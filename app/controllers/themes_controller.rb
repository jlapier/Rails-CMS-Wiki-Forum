class ThemesController < ApplicationController
  before_filter :require_admin_user, :except => [ :colors, :css, :images ]
  
  caches_page :colors, :css
  
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
    if params[:name] == "screen"
      @css = SiteSetting.read_setting('css screen override') ||
        File.read( File.join(Rails.root, 'public', 'stylesheets', 'screen.css') )
    else
      @css = SiteSetting.read_setting('css override') || ''
    end
  end

  def update_css
    if params[:name] == "screen"
      expire_page "/themes/css/screen_override.css"
      SiteSetting.write_setting('css screen override', params[:css])
      SiteSetting.write_setting('css screen override timestamp', Time.now.to_i)
    else
      expire_page "/themes/css/override.css"
      SiteSetting.write_setting('css override', params[:css])
      SiteSetting.write_setting('css override timestamp', Time.now.to_i)
    end
    flash[:notice] = "CSS override updated."
    redirect_to :action => :css_editor, :name => params[:name]
  end

  def css
    if params[:name] == "screen_override"
      @override = @css_screen_override
      @timestamp = @css_screen_override_timestamp
    else
      @override = @css_override
      @timestamp = @css_override_timestamp
    end
  end

  def images
  end

  def update_theme_settings
    SiteSetting.write_setting 'theme layout', params[:theme_layout]
    SiteSetting.write_setting 'theme skin', params[:theme_skin]
    SiteSetting.write_setting 'theme colors', params[:theme_colors]
    flash[:notice] = "Theme configuration updated."
    redirect_to :action => :index
  end
end
