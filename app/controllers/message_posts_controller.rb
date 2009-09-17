class MessagePostsController < ApplicationController
  before_filter :require_user, :except => [:index, :show]

  # GET /message_posts
  # GET /message_posts.xml
  def index
    @message_posts = MessagePost.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @message_posts }
    end
  end

  # GET /message_posts/1
  # GET /message_posts/1.xml
  def show
    @message_post = MessagePost.find(params[:id])
    if @message_post.thread
      redirect_to message_post_url(@message_post.thread, :anchor => @message_post.id)
    else
      @child_posts = @message_post.child_posts.paginate :page => params[:page], :order => 'created_at ASC'
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @message_post }
      end
    end
  end

  # GET /message_posts/new
  # GET /message_posts/new.xml
  def new
    @message_post = MessagePost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message_post }
    end
  end

  # GET /message_posts/1/edit
  def edit
    @message_post = MessagePost.find(params[:id])
  end

  # POST /message_posts
  # POST /message_posts.xml
  def create
    @message_post = MessagePost.new(params[:message_post])
    @message_post.user = current_user
    respond_to do |format|
      if @message_post.save
        flash[:notice] = "Posted: #{@message_post.subject}"
        format.html do
          if @message_post.thread
            redirect_to message_post_url(@message_post.thread, :anchor => @message_post.id,
              :page => @message_post.thread.child_posts.last_page_number_for)
          else
            redirect_to(@message_post)
          end
        end
        format.xml  { render :xml => @message_post, :status => :created, :location => @message_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @message_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /message_posts/1
  # PUT /message_posts/1.xml
  def update
    @message_post = MessagePost.find(params[:id])

    respond_to do |format|
      if @message_post.update_attributes(params[:message_post])
        flash[:notice] = 'MessagePost was successfully updated.'
        format.html { redirect_to(@message_post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /message_posts/1
  # DELETE /message_posts/1.xml
  def destroy
    @message_post = MessagePost.find(params[:id])
    @message_post.destroy

    respond_to do |format|
      format.html { redirect_to(message_posts_url) }
      format.xml  { head :ok }
    end
  end
end
