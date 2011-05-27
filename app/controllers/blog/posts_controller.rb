module Blog
  class PostsController < ApplicationController
    before_filter :require_authorization, :except => [:index, :show]
    include BlogHelper
  private
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
      post
    end
  
    def create
      post.author = current_user
      if post.save
        respond_to do |format|
          append = current_user.is_admin? ? '' : ' Publication is pending moderator approval.'
          format.html{ redirect_to edit_blog_post_path(post), :notice => "Saved post: #{post.title}.#{append}" }
        end
      else
        render :new
      end
    end

    def edit
      record_editing_user_for(post)
      @rel_dir = asset_path_for post, :relative
      @assets = list_assets_for post
    end
    
    def update
      if post.update_attributes params[:blog_post]
        remove_editing_user_record_for post
        respond_to do |format|
          format.html{ redirect_to blog_post_path(post), :notice => "Updated post: #{post.title}"}
        end
      else
        @rel_dir = asset_path_for post, :relative
        @assets = list_assets_for post
        render :edit
      end
    end
    
    def upload_handler
      rel_dir = save_asset_for post, params[:upload]

      render :text => "<html><body><script type=\"text/javascript\">" +
        "parent.CKEDITOR.tools.callFunction( #{params[:CKEditorFuncNum]}, '/#{rel_dir}/#{params[:upload].original_filename}' )" +
        "</script></body></html>"
    end

    def delete_asset
      if rm_asset_for post, params[:asset]
        flash[:notice] = "#{params[:asset]} deleted."
      else
        flash[:error] = "Unable to delete #{params[:asset]}."
      end
      redirect_to edit_blog_post_path(post)
    end
    
    def un_edit
      remove_editing_user_record_for post

      respond_to do |wants|
        wants.html do
          flash[:notice] = "Post <em>#{post.title}</em> was not changed."
          redirect_to blog_posts_path
        end
        wants.js { render :nothing => true }
      end
    end

    def show
      unless post.published or (current_user and current_user.logged_in?)
        redirect_to blog_posts_path, :notice => "Not Found." and return
      end
      comments # load @comments
    end
  
    def destroy
      post.destroy
      respond_to do |format|
        format.html{ redirect_to blog_posts_path, :notice => "Deleted post: #{post.title}" }
      end
    end
    
    def publish
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