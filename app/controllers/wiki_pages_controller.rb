class WikiPagesController < ApplicationController
  before_filter :get_tags

  before_filter  do |controller|
    if [:index, :show, :tag_index, :tagcloud, :search, :show_by_title, :history, :chatter].include? controller.params[:action].to_sym
      controller.require_group_access(["Wiki Reader", "Wiki Editor"])
    else
      controller.require_group_access("Wiki Editor")
    end
  end
  
  
  def index
    @wiki_pages = WikiPage.paginate :all, :page => params[:page],
      :order => "updated_at DESC", :select => "id, title, url_title, updated_at"
    @wiki_tags = WikiTag.find :all
  end
  
  def tag_index
    
  end
  
  def tagcloud
    render :json => @wiki_tags.map {|wt| { 'tag' => wt.name, 'freq' => wt.wiki_pages.count } }
  end
  
  def list_by_tag
    @wiki_tag = WikiTag.find :first, :conditions => { :name => params[:tag_name] }
    if @wiki_tag
      @wiki_pages = @wiki_tag.wiki_pages.paginate :all, :page => params[:page], :per_page => 80,
        :order => "updated_at DESC", :select => "wiki_pages.id, title, url_title, updated_at"
      render :action => :index
    else
      flash[:warning] = "Tag not found."
      redirect_to wiki_page_show_home_path
    end
  end
  
  def show
    @wiki_page = WikiPage.find params[:id]
  end
  
  def show_by_title
    @wiki_page = WikiPage.find_by_url_title params[:title]
    if @wiki_page
      render :action => :show
    else
      flash[:notice] = "<em>#{params[:title]}</em> was not found. You may create this page now if you wish."
      redirect_to :action => :new, :title => params[:title]
    end
  end
  
  def history
    @wiki_page = WikiPage.find_by_url_title params[:title]
    if @wiki_page
      @wiki_page_versions = @wiki_page.versions.find(:all, :limit => 20).reverse
    else
      flash[:notice] = "<em>#{params[:title]}</em> was not found. You may create this page now if you wish."
      redirect_to :action => :new, :title => params[:title]
    end
  end

  def bookmark
    to_bm = params[:title] ? WikiPage.find_by_url_title(params[:title]) : params[:url]
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
    @wiki_page = WikiPage.find params[:id]
    unless @wiki_page.editing_user
      @wiki_page.update_attributes :editing_user => current_user, :started_editing_at => Time.now
    end
    @rel_dir = File.join "wiki_page_assets", "wiki_page_#{@wiki_page.id}"
    @assets = Dir[File.join(RAILS_ROOT, 'public', @rel_dir, '*')].map { |f| File.basename(f) }
  end
  
  def new
    @wiki_page = WikiPage.new :title => params[:title]
  end
  
  def create
    @wiki_page = WikiPage.new params[:wiki_page]
    @wiki_page.modifying_user = current_user
    if @wiki_page.save
      flash[:notice] = "New page <em>#{@wiki_page.title}</em> created."
      redirect_to wiki_page_edit_path(@wiki_page)
    else
      render :action => :new
    end
  end
  
  def update
    @wiki_page = WikiPage.find params[:id]
    @wiki_page.modifying_user = current_user
    if @wiki_page.update_attributes params[:wiki_page]
      @wiki_page.update_attributes :editing_user => nil, :started_editing_at => nil
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Page <em>#{@wiki_page.title}</em> updated."
          redirect_to wiki_page_show_path(:title => @wiki_page.url_title)
        end
        wants.js do
          render :update do |page|
            page['my_notes_saved'].show
            page['my_notes_saved'].visual_effect :pulsate
            page.delay(5) { page['my_notes_saved'].visual_effect :fade }
          end
        end
      end
    else
      render :action => :edit
    end     
  end

  def destroy
    @wiki_page = WikiPage.find params[:id]
    if @wiki_page.destroy
      flash[:notice] = "<em>#{@wiki_page.title}</em> was deleted."
    end

    respond_to do |format|
      format.html { redirect_to(wiki_page_index_url) }
      format.xml  { head :ok }
    end
  end

  # TODO: write the js to call this via ajax
  def live_search
    # only search if we have at least 3 letters
    if params[:name].length > 2
      
      # assume they are typing start of first or last name
      @name_part = params[:name]
      @wiki_pages = WikiPage.find_like @name_part
      @wiki_tags = WikiTag.find_like @name_part
      render :partial => "live_search_results"
    else
      render :nothing => true
    end
  end

  def search
    @name_part = params[:name]
    @wiki_pages = WikiPage.search @name_part
    @wiki_tags = WikiTag.search @name_part
  end
  
  def homepage
    @wiki_page = WikiPage.find_or_create_by_title("Home Page")
    render :action => :show
  end
  
  def upload_handler
    @wiki_page = WikiPage.find params[:id]
    file_name = params[:upload].original_filename
    # break it up into file and extension
    # we need this to check the types and to build new names if necessary
    rel_dir = File.join "wiki_page_assets", "wiki_page_#{@wiki_page.id}"
    actual_dir = File.join(RAILS_ROOT, 'public', rel_dir)
    FileUtils.mkdir_p actual_dir
    File.open(File.join(actual_dir, file_name), 'wb') do |f|
      f.write(params[:upload].read)
    end

    render :text => "<html><body><script type=\"text/javascript\">" +
      "parent.CKEDITOR.tools.callFunction( #{params[:CKEditorFuncNum]}, '/#{rel_dir}/#{file_name}' )" +
      "</script></body></html>"
  end

  def page_link_handler
    @wiki_page = WikiPage.find params[:id]
    @wiki_pages = WikiPage.find :all
    render :action => :page_link_handler, :layout => 'minimal'
  end

  def delete_asset
    @content_page = ContentPage.find params[:id]
    file = File.join RAILS_ROOT, 'public', "content_page_assets", "content_page_#{@content_page.id}", params[:asset]
    if File.exists?(file) and File.delete(file)
      flash[:notice] = "#{File.basename(file)} deleted."
    else
      flash[:error] = "Unable to delete #{File.basename(file)}."
    end
    redirect_to edit_content_page_path(@content_page)
  end

  private
  def get_tags
    all_wiki_tags = WikiTag.find :all
    @wiki_tags, to_delete = all_wiki_tags.partition { |wt| wt.wiki_pages.count > 0 }
    @wiki_tags = @wiki_tags.sort_by { |wt| wt.wiki_pages_count }.reverse
    to_delete.map(&:destroy)
  end
end
