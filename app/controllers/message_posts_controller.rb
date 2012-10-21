class MessagePostsController < ApplicationController
  before_filter :require_user, :except => [:index, :show]
  before_filter :get_forum, :only => [:index, :show, :edit, :update, :create, :destroy]
  before_filter :require_forum_read_access, :only => [:show, :index]
  before_filter :require_forum_write_access, :only => [:edit, :update, :destroy, :upload_handler]


  def index
    redirect_to @forum
  end

  # GET /forums/1/message_posts/1
  # GET /forums/1/message_posts/1.xml
  def show
    @message_post = MessagePost.find(params[:id]) #@forum.message_posts.find(params[:id])
    if @message_post.thread
      redirect_to forum_message_post_url(@forum, @message_post.thread, :anchor => @message_post.id)
    else
      @child_posts = @message_post.child_posts.paginate :page => params[:page], :order => 'created_at ASC'
      @followers = @message_post.followers 
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @message_post }
        format.atom
        format.rss
      end
    end
  end

  # GET /forums/1/message_posts/new
  # GET /forums/1/message_posts/new.xml
  def new
    @message_post = MessagePost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message_post }
    end
  end

  # GET /forums/1/message_posts/1/edit
  def edit
    @message_post = MessagePost.find(params[:id])
  end

  # POST /forums/1/message_posts
  # POST /forums/1/message_posts.xml
  def create
    @message_post = MessagePost.new(params[:message_post])
    @message_post.forum = @forum unless @message_post.thread
    @message_post.user = current_user
    respond_to do |format|
      if @message_post.save
        flash[:notice] = "Posted: #{@message_post.subject}"
        format.html do
          if @message_post.thread
              @message_post.thread.update_attribute(:updated_at, Time.now)
              @message_post.thread.followers.each do |poster|
                Notifier.email_follower( @message_post, poster).deliver
              end
              redirect_to forum_message_post_url(@forum, @message_post.thread, :anchor => @message_post.id,
              :page => @message_post.thread.child_posts.last_page_number_for)
          else
            redirect_to forum_message_post_url(@forum, @message_post)
          end
        end
        format.xml  { render :xml => @message_post, :status => :created, :location => @message_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @message_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forums/1/message_posts/1
  # PUT /forums/1/message_posts/1.xml
  def update
    @message_post = MessagePost.find(params[:id]) #@forum.message_posts.find(params[:id])

    respond_to do |format|
      if @message_post.update_attributes(params[:message_post])
        flash[:notice] = 'MessagePost was successfully updated.'
        format.html { redirect_to forum_message_post_url(@forum, @message_post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forums/1/message_posts/1
  # DELETE /forums/1/message_posts/1.xml
  def destroy
    @message_post = MessagePost.find(params[:id]) #@forum.message_posts.find(params[:id])
    @message_post.destroy

    respond_to do |format|
      flash[:notice] = "Post '#{@message_post.subject}' deleted."
      format.html { redirect_to(@forum) }
      format.xml  { head :ok }
    end
  end


  # DELETE /forums/1/message_posts/1/stop_following
  # DELETE /forums/1/message_posts/1.xml/stop_following
  def stop_following
    @message_post = MessagePost.find(params[:id]) #@forum.message_posts.find(params[:id])
    posts = @message_post.posts_with_followers
    posts.each do |post|
      if post.user == current_user
          post.update_attribute(:to_user_id, 0)
      end
    end
    respond_to do |format|
      flash[:notice] = "Stopped following Post '#{@message_post.subject}'."
      format.html { redirect_to forum_message_post_url(@forum, @message_post.thread) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def get_forum
    @forum ||= Forum.find(params[:forum_id])
  end
  def single_access_allowed?
    action_name == 'show'
  end
end
