class ThemesController < ApplicationController
  before_filter :require_admin_user, :only => [ :index, :update_theme_settings ]

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
    @css = "body { background: #EFA }"
  end

  def css
  end

  def images
  end

  def update_theme_settings
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
