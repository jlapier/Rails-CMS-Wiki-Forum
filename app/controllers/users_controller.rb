class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update, :upload_handler]
  before_filter :require_admin_user, :only => [:index, :update_password, :password_reset, :destroy, :make_admin, :unmake_admin]

  def index
    @users = User.find(:all, :order => 'first_name ASC' )
  end

  def new
    reg_pass = SiteSetting.read_setting 'registration password'
    if !reg_pass.blank? and reg_pass != params[:p]
      flash[:warning] = "Registration is currently password protected on this site."
      redirect_to :action => :reg_pass_required
    end
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def show
    if params[:id]
      require_admin_user
      @user = User.find(params[:id])
    else
      @user = @current_user
    end
  end

  def edit
    if params[:id]
      require_admin_user
      @user = User.find(params[:id])
    else
      @user = @current_user
    end
  end
  
  def update
    if params[:id]
      require_admin_user
      @user = User.find(params[:id])
    else
      @user = @current_user
    end
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      if params[:id]
        redirect_to edit_user_path(@user)
      else
        redirect_to account_url
      end
    else
      render :action => :edit
    end
  end

  def make_admin
    @user = User.find(params[:id])
    @user.is_admin = true
    @user.save
    flash[:notice] = "#{@user.fullname} is now an admin."
    redirect_to users_path
  end

  def unmake_admin
    @user = User.find(params[:id])
    if @user != current_user
      @user.is_admin = false
      @user.save
      flash[:notice] = "#{@user.fullname} is no longer an admin."
    else
      flash[:warning] = "You can't revoke your own admin rights. Get someone else to do it."
    end
    redirect_to users_path
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "Account <em>#{@user.login} (#{@user.full_name})</em> deleted."
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def upload_handler
    @user = User.find(params[:id])
    rel_dir = File.join "user_assets", "user_#{@user.id}"
    write_file(params[:upload], rel_dir)

    render :text => "<html><body><script type=\"text/javascript\">" +
      "parent.CKEDITOR.tools.callFunction( #{params[:CKEditorFuncNum]}, '/#{rel_dir}/#{params[:upload].original_filename}' )" +
      "</script></body></html>"
  end

end
