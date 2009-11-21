class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  before_filter :require_admin_user, :only => [:index, :update_password, :password_reset]

  def index
    if params[:disabled] == "1"
      @users = UserGroup.find_or_create_by_name('Disabled Users').users
    else
      @users = User.find(:all, :include => :user_groups, :order => 'first_name ASC' )
    end
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
        redirect_to users_path
      else
        redirect_to account_url
      end
    else
      render :action => :edit
    end
  end

end
