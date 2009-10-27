class WikiPagesController < ApplicationController
  def index
    @wiki_pages = WikiPage.paginate :all, :page => params[:page],
      :order => "updated_at DESC", :select => "id, title, url_title, updated_at"
    @wiki_tags = WikiTag.find :all
  end
  
  def tag_index
    all_wiki_tags = WikiTag.find :all
    @wiki_tags, to_delete = all_wiki_tags.partition { |wt| wt.wiki_pages.count > 0 }
    @wiki_tags = @wiki_tags.sort_by { |wt| wt.wiki_pages_count }.reverse
    to_delete.map(&:destroy)
  end
  
  def tagcloud
    all_wiki_tags = WikiTag.find :all
    @wiki_tags, to_delete = all_wiki_tags.partition { |wt| wt.wiki_pages.count > 0 }
    to_delete.map(&:destroy)
    @wiki_tags = @wiki_tags.sort_by { |wt| wt.wiki_pages.count }.reverse[0..30]
#    counts = @wiki_tags.map { |wt| wt.wiki_pages.count }
#    @min_count = counts.min
#    max_count = counts.max
#    middle_count = counts.reject { |cnt| cnt == @min_count or cnt == max_count }
#    @count_factor = 14 / (middle_count.size + 1)
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
  end
  
  def new
    @wiki_page = WikiPage.new :title => params[:title]
  end
  
  def create
    @wiki_page = WikiPage.new params[:wiki_page]
    @wiki_page.modifying_user = current_user
    if @wiki_page.save
      flash[:notice] = "New page <em>#{@wiki_page.title}</em> created."
      redirect_to wiki_page_show_path(:title => @wiki_page.url_title)
    else
      render :action => :new
    end
  end
  
  def update
    @wiki_page = WikiPage.find params[:id]
    @wiki_page.modifying_user = current_user
    if @wiki_page.update_attributes params[:wiki_page]
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
  
  def homepage
    @wiki_page = WikiPage.find_or_create_by_title("Home Page")
    render :action => :show
  end
  
  def chatter
    @comments = WikiComment.find :all, :limit => 40, :include => [:wiki_page, :user], :order => "created_at DESC"
  end
end
