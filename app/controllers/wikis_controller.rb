class WikisController < ApplicationController
  before_filter :require_admin_user, :except => [:index, :show, :tag_index, :tagcloud, :list_by_tag]

  # GET /wikis
  # GET /wikis.xml
  def index
    @wikis = Wiki.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wikis }
    end
  end

  # GET /wikis/1
  # GET /wikis/1.xml
  def show
    @wiki = Wiki.find(params[:id])
    @wiki_pages = @wiki.wiki_pages.paginate :all, :page => params[:page],
      :order => "updated_at DESC", :select => "id, title, url_title, updated_at"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @wiki }
    end
  end

  # GET /wikis/new
  # GET /wikis/new.xml
  def new
    @wiki = Wiki.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wiki }
    end
  end

  # GET /wikis/1/edit
  def edit
    @wiki = Wiki.find(params[:id])
  end

  # POST /wikis
  # POST /wikis.xml
  def create
    @wiki = Wiki.new(params[:wiki])

    respond_to do |format|
      if @wiki.save
        flash[:notice] = 'Wiki was successfully created.'
        format.html { redirect_to(@wiki) }
        format.xml  { render :xml => @wiki, :status => :created, :location => @wiki }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wiki.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /wikis/1
  # PUT /wikis/1.xml
  def update
    @wiki = Wiki.find(params[:id])

    respond_to do |format|
      if @wiki.update_attributes(params[:wiki])
        flash[:notice] = 'Wiki was successfully updated.'
        format.html { redirect_to(@wiki) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wiki.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /wikis/1
  # DELETE /wikis/1.xml
  def destroy
    @wiki = Wiki.find(params[:id])
    @wiki.destroy

    respond_to do |format|
      format.html { redirect_to(wikis_url) }
      format.xml  { head :ok }
    end
  end




  def tag_index

  end


  def list_by_tag
    @wiki_tag = WikiTag.find :first, :conditions => { :name => params[:tag_name] }
    if @wiki_tag
      @wiki.wiki_pages = @wiki_tag.wiki_pages.paginate :all, :page => params[:page], :per_page => 80,
        :order => "updated_at DESC", :select => "wiki_pages.id, title, url_title, updated_at"
      render :action => :index
    else
      flash[:warning] = "Tag not found."
      redirect_to wiki_page_show_home_path
    end
  end

  
  def tagcloud
    @wiki_tags = WikiTag.find :all
    render :json => @wiki_tags.map {|wt| { 'tag' => wt.name, 'freq' => wt.wiki_pages.count } }
  end
end
