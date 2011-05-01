class ForumsController < ApplicationController

  before_filter :require_admin_user, :except => [:index, :show]
  before_filter :get_forum, :only => [:show, :edit, :update, :destroy, :search]
  before_filter :require_forum_read_access, :only => [:show]
  before_filter :require_forum_write_access, :only => [:edit, :update, :destroy]

  # GET /forums
  # GET /forums.xml
  def index
    @forums = Forum.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forums }
    end
  end

  # GET /forums/1
  # GET /forums/1.xml
  def show
    user_groups = UserGroup.find_all_with_access_to @forum
    @users_with_access = user_groups.map(&:users).flatten.uniq
    @message_posts = @forum.message_posts.paginate :page => params[:page], :order => 'created_at DESC'
    @new_message_post = MessagePost.new :forum => @forum
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @forum }
      format.rss
    end
  end

  # GET /forums/new
  # GET /forums/new.xml
  def new
    @forum = Forum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @forum }
    end
  end

  # GET /forums/1/edit
  def edit
    @forum = Forum.find(params[:id])
  end

  # POST /forums
  # POST /forums.xml
  def create
    @forum = Forum.new(params[:forum])

    respond_to do |format|
      if @forum.save
        flash[:notice] = "Forum #{@forum.name} was successfully created."
        format.html { redirect_to forums_path }
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forums/1
  # PUT /forums/1.xml
  def update
    respond_to do |format|
      if @forum.update_attributes(params[:forum])
        flash[:notice] = "Forum #{@forum.name} was successfully updated."
        format.html { redirect_to(@forum) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forums/1
  # DELETE /forums/1.xml
  def destroy
    @forum.destroy

    respond_to do |format|
      format.html { redirect_to(forums_url) }
      format.xml  { head :ok }
    end
  end

  def search
    @search_term = params[:q]
    if @search_term.blank?
      redirect_to :action => :index
    end
    @message_posts = @forum.message_posts.search_forums(@search_term).paginate
  end

  protected
  def get_forum
    @forum ||= Forum.find(params[:id])
  end
  
  def single_access_allowed?
    action_name == 'show'
  end
end
