class WikiPagesController < ApplicationController
  before_filter :get_wiki
  before_filter :get_tags, :only => [:new, :edit, :create, :update]
  before_filter :require_wiki_read_access, :only => [:show, :history, :homepage, :index, :live_search, :search, :show_by_title]
  before_filter :require_wiki_write_access, :only => [:edit, :update, :destroy, :create, :delete_asset, :un_edit, :upload_handler]
  
  
  def index
    redirect_to @wiki
  end
    
  def show
    @wiki_page = @wiki.wiki_pages.find params[:id]
  end
  
  def show_by_title
    @wiki_page = @wiki.wiki_pages.find_by_url_title params[:title]
    if @wiki_page
      render :action => :show
    else
      flash[:notice] = "<em>#{params[:title]}</em> was not found. You may create this page now if you wish."
      redirect_to new_wiki_wiki_page_path(@wiki, :title => params[:title])
    end
  end
  
  def history
    @wiki_page = @wiki.wiki_pages.find params[:id]
    @wiki_page_versions = @wiki_page.versions.find(:all, :limit => 20).reverse
  end

  def bookmark
    to_bm = params[:title] ? @wiki.wiki_pages.find_by_url_title(params[:title]) : params[:url]
    unless to_bm.nil?
      if current_user.has_bookmarked?(to_bm)
        current_user.remove_bookmark(to_bm)
      else
        @added = current_user.save_bookmark(to_bm)
      end
      render :update do |page|
        if params[:from_front_page]
          page['your_bookmarks'].update render(:partial => 'your_bookmarks')
        elsif @added
          page['bookmark-star'].src = '/images/star-yellow.png'
        else
          page['bookmark-star'].src = '/images/star-clear.png'
        end
      end
    end
  end
  
  def edit
    @wiki_page = @wiki.wiki_pages.find params[:id]
    unless @wiki_page.editing_user
      @wiki_page.update_attributes :editing_user => current_user, :started_editing_at => Time.now
    end
    @rel_dir = File.join "wiki_page_assets", "wiki_page_#{@wiki_page.id}"
    @assets = Dir[File.join(RAILS_ROOT, 'public', @rel_dir, '*')].map { |f| File.basename(f) }
  end
  
  def new
    title = params[:title] ? params[:title].respace : ''
    @wiki_page = WikiPage.new :title => title
  end
  
  def create
    @wiki_page = WikiPage.new params[:wiki_page].merge(:wiki_id => @wiki.id)
    @wiki_page.modifying_user = current_user
    if @wiki_page.save
      flash[:notice] = "New page <em>#{@wiki_page.title}</em> created."
      redirect_to edit_wiki_wiki_page_path(@wiki, @wiki_page)
    else
      render :action => :new
    end
  end
  
  def update
    @wiki_page = @wiki.wiki_pages.find params[:id]
    @wiki_page.modifying_user = current_user
    if @wiki_page.update_attributes params[:wiki_page]
      @wiki_page.update_attributes :editing_user => nil, :started_editing_at => nil
      flash[:notice] = "Page <em>#{@wiki_page.title}</em> updated."
      redirect_to wiki_pages_show_by_title_path(@wiki, @wiki_page.url_title)
    else
      render :action => :edit
    end     
  end

  # called when someone willingly navigates away
  def un_edit
    @wiki_page = @wiki.wiki_pages.find params[:id]
    if @wiki_page.editing_user == current_user
      @wiki_page.update_attributes :editing_user => nil, :started_editing_at => nil
    end

    respond_to do |wants|
      wants.html do
        flash[:notice] = "Page <em>#{@wiki_page.title}</em> was not changed."
        redirect_to wiki_pages_show_by_title_path(@wiki, @wiki_page.url_title)
      end
      wants.js { render :nothing => true }
    end
  end

  def destroy
    @wiki_page = @wiki.wiki_pages.find params[:id]
    if @wiki_page.destroy
      flash[:notice] = "<em>#{@wiki_page.title}</em> was deleted."
    end

    respond_to do |format|
      format.html { redirect_to(@wiki) }
      format.xml  { head :ok }
    end
  end

  # TODO: write the js to call this via ajax
  def live_search
    # only search if we have at least 3 letters
    if params[:name].length > 2
      
      # assume they are typing start of first or last name
      @name_part = params[:name]
      @wiki_pages = @wiki.wiki_pages.find_like @name_part
      @wiki_tags = WikiTag.find_like @name_part
      render :partial => "live_search_results"
    else
      render :nothing => true
    end
  end

  def search
    @name_part = params[:name]
    @wiki_pages = @wiki.wiki_pages.search @name_part
    @wiki_tags = @wiki.wiki_tags.search @name_part
  end

  
  def upload_handler
    @wiki_page = @wiki.wiki_pages.find params[:id]
    rel_dir = File.join "wiki_page_assets", "wiki_page_#{@wiki_page.id}"
    write_file(params[:upload], rel_dir)

    render :text => "<html><body><script type=\"text/javascript\">" +
      "parent.CKEDITOR.tools.callFunction( #{params[:CKEditorFuncNum]}, '/#{rel_dir}/#{params[:upload].original_filename}' )" +
      "</script></body></html>"
  end

  def page_link_handler
    @wiki_page = @wiki.wiki_pages.find params[:id]
    @wiki_pages = @wiki.wiki_pages
    render :action => :page_link_handler, :layout => 'minimal'
  end

  def delete_asset
    @wiki_page = @wiki.wiki_pages.find params[:id]
    file = File.join RAILS_ROOT, 'public', "wiki_page_assets", "wiki_page_#{@wiki_page.id}", params[:asset]
    if File.exists?(file) and File.delete(file)
      flash[:notice] = "#{File.basename(file)} deleted."
    else
      flash[:error] = "Unable to delete #{File.basename(file)}."
    end
    redirect_to edit_wiki_wiki_page_path(@wiki, @wiki_page)
  end

  private

  def get_wiki
    @wiki = Wiki.find params[:wiki_id]
  end

  def get_tags
    @wiki_tags = @wiki.wiki_tags
    @wiki_tags = @wiki_tags.sort_by { |wt| wt.wiki_pages_count }.reverse
  end
end
