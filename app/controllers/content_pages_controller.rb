class ContentPagesController < ApplicationController
  before_filter :require_admin_user, :except => [:home, :index, :show, :search]
  before_filter :expire_content_page_caches, :only => [:update, :destroy, :delete_asset]

  def home
    @content_page = ContentPage.get_front_page
    @page_layout_file = File.join(Rails.root, "/themes/page_layouts/#{@content_page.page_layout || 'default'}")
    unless @content_page.layout.blank?
      @special_layout_file = File.join(Rails.root, "/themes/layouts/#{@content_page.layout}.html.erb")
    end
    render :action => :show
  end

  # GET /content_pages
  # GET /content_pages.xml
  def index
    @content_pages = ContentPage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @content_pages }
    end
  end

  # GET /content_pages/1
  # GET /content_pages/1.xml
  def show
    if !fragment_exist?({}) or (current_user and current_user.is_admin?)
      @content_page = ContentPage.find(params[:id])
      @page_layout_file = File.join(Rails.root, "/themes/page_layouts/#{@content_page.page_layout || 'default'}")
    else
      @content_page = ContentPage.select('layout, name, is_preview_only, publish_on').find(params[:id])
    end
    unless @content_page.layout.blank?
      @special_layout_file = File.join(Rails.root, "/themes/layouts/#{@content_page.layout}.html.erb")
    end
    if @content_page.ready_for_publishing? or (current_user and current_user.is_admin?)
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @content_page }
      end
    else
      flash[:warning] = "That page is currently unavailable."
      redirect_to content_pages_path
    end
  end

  # GET /content_pages/new
  # GET /content_pages/new.xml
  def new
    @content_page = ContentPage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @content_page }
    end
  end

  # GET /content_pages/1/edit
  def edit
    @content_page = ContentPage.find(params[:id])
    unless @content_page.editing_user
      @content_page.update_attributes :editing_user => current_user, :started_editing_at => Time.now
    end
    @rel_dir = File.join "content_page_assets", "content_page_#{@content_page.id}"
    @assets = Dir[File.join(Rails.root, 'public', @rel_dir, '*')].map { |f| File.basename(f) }
  end

  # POST /content_pages
  # POST /content_pages.xml
  def create
    @content_page = ContentPage.new(params[:content_page])
    respond_to do |format|
      if @content_page.save
        if params[:new_category] and !params[:new_category].blank?
          cat = Category.find_or_create_by_name params[:new_category]
          @content_page.categories << cat
          @content_page.save
        end
        flash[:notice] = "Page <em>#{@content_page.name}</em> was created."
        format.html { redirect_to(edit_content_page_path(@content_page)) }
        format.xml  { render :xml => @content_page, :status => :created, :location => @content_page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /content_pages/1
  # PUT /content_pages/1.xml
  def update
    @content_page = ContentPage.find(params[:id])
    respond_to do |format|
      if @content_page.update_attributes(params[:content_page])
        @content_page.update_attributes :editing_user => nil, :started_editing_at => nil
        if params[:content_page][:category_ids].blank?
          @content_page.categories = []
        end
        if params[:new_category] and !params[:new_category].blank?
          cat = Category.find_or_create_by_name params[:new_category]
          @content_page.categories << cat
          @content_page.save
        end
        flash[:notice] = "Page <em>#{@content_page.name}</em> was updated."
        format.html { redirect_to(@content_page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # called when someone willingly navigates away
  def un_edit
    @content_page = ContentPage.find params[:id]
    if @content_page.editing_user == current_user
      @content_page.update_attributes :editing_user => nil, :started_editing_at => nil
    end

    respond_to do |wants|
      wants.html do
        flash[:notice] = "Page <em>#{@content_page.title}</em> was not changed."
        redirect_to @content_page
      end
      wants.js { render :nothing => true }
    end
  end

  # DELETE /content_pages/1
  # DELETE /content_pages/1.xml
  def destroy
    @content_page = ContentPage.find(params[:id])
    @content_page.destroy

    respond_to do |format|
      format.html { redirect_to(content_pages_url) }
      format.xml  { head :ok }
    end
  end


  def upload_handler
    @content_page = ContentPage.find params[:id]
    file_name = params[:upload].original_filename
    # break it up into file and extension
    # we need this to check the types and to build new names if necessary
    rel_dir = File.join "content_page_assets", "content_page_#{@content_page.id}"
    actual_dir = File.join(Rails.root, 'public', rel_dir)
    FileUtils.mkdir_p actual_dir
    File.open(File.join(actual_dir, file_name), 'wb') do |f|
      f.write(params[:upload].read)
    end

    render :text => "<html><body><script type=\"text/javascript\">" +
      "parent.CKEDITOR.tools.callFunction( #{params[:CKEditorFuncNum]}, '/#{rel_dir}/#{file_name}' )" +
      "</script></body></html>"
  end

  def delete_asset
    @content_page = ContentPage.find params[:id]
    file = File.join Rails.root, 'public', "content_page_assets", "content_page_#{@content_page.id}", params[:asset]
    if File.exists?(file) and File.delete(file)
      flash[:notice] = "#{File.basename(file)} deleted."
    else
      flash[:error] = "Unable to delete #{File.basename(file)}."
    end
    redirect_to edit_content_page_path(@content_page)
  end

  def search
    @search_phrase = params[:q]
    @content_pages = ContentPage.search @search_phrase 
    @categories = Category.search @search_phrase
    render :action => :index
  end

end
