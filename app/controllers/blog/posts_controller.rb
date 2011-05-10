module Blog
  class PostsController < ApplicationController
    before_filter :require_user, :except => [:index, :show]
    before_filter :require_authorization, :except => [:index, :show]
  private
  
    # find Post from params[:id] or new params[:blog_post]
    def post
      begin
        @post ||= Post.find params[:id]
      rescue ActiveRecord::RecordNotFound => e
        @post = Post.new params[:blog_post]
      end
    end

    def require_authorization
      unless has_authorization? action_name.to_sym, post
        redirect_to blog_posts_path, :notice => "Not Found." and return
      end
    end
  public
    def index
      @posts = Post.order("created_at DESC, published")
      @posts = @posts.published unless current_user and current_user.logged_in?
    end

    def new
      @post = Post.new
    end
  
    def create
      @post = Post.new params[:blog_post]
      @post.author = current_user
      if @post.save
        respond_to do |format|
          append = current_user.is_admin? ? '' : ' Publication is pending moderator approval.'
          format.html{ redirect_to edit_blog_post_path(@post), :notice => "Saved post: #{@post.title}.#{append}" }
        end
      else
        render :new
      end
    end

    def edit
      @post = Post.find params[:id]
      record_editing_user_for(@post)
      @rel_dir = asset_path_for @post, :relative
      @assets = list_assets_for @post
    end
    
    def update
      @post = Post.find params[:id]
      if @post.update_attributes params[:blog_post]
        remove_editing_user_record_for @post
        respond_to do |format|
          format.html{ redirect_to blog_post_path(@post), :notice => "Updated post: #{@post.title}"}
        end
      else
        @rel_dir = asset_path_for @post, :relative
        @assets = list_assets_for @post
        render :edit
      end
    end
    
    def upload_handler
      @post = Post.find params[:id]

      rel_dir = save_asset_for @post, params[:upload]

      render :text => "<html><body><script type=\"text/javascript\">" +
        "parent.CKEDITOR.tools.callFunction( #{params[:CKEditorFuncNum]}, '/#{rel_dir}/#{params[:upload].original_filename}' )" +
        "</script></body></html>"
    end

    def delete_asset
      @post = Post.find params[:id]
      if rm_asset_for @post, params[:asset]
        flash[:notice] = "#{params[:asset]} deleted."
      else
        flash[:error] = "Unable to delete #{params[:asset]}."
      end
      redirect_to edit_blog_post_path(@post)
    end
    
    def un_edit
      @post = Post.find params[:id]
      remove_editing_user_record_for @post

      respond_to do |wants|
        wants.html do
          flash[:notice] = "Post <em>#{@post.title}</em> was not changed."
          redirect_to blog_posts_path
        end
        wants.js { render :nothing => true }
      end
    end

    def show
      @post = Post.find params[:id]
      unless @post.published or (current_user and current_user.logged_in?)
        redirect_to blog_posts_path, :notice => "Not Found." and return
      end
    end
  
    def destroy
      post = Post.destroy params[:id]
      respond_to do |format|
        format.html{ redirect_to blog_posts_path, :notice => "Deleted post: #{post.title}" }
      end
    end
    
    def publish
      post = Post.find params[:id]
      if post.toggle_published
        pre = post.published ? 'Published' : 'Unpublished'
        msg = "#{pre} post: #{post.title}!"
      else
        pre = post.published ? 'Unpublication' : 'Publication'
        msg = "#{pre} failed, please try again."
      end
      respond_to do |format|
        format.html{ redirect_to blog_post_path(post), :notice => msg }
      end
    end
  end
end