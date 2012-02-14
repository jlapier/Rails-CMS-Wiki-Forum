class UserSessionsController < ApplicationController
  before_filter RubyCAS::Filter, :only => :cas_login
  before_filter :require_no_user, :only => [:create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default '/'
    else
      flash[:error] = "Unable to login. Bad username or password?"
      redirect_to login_url
    end
    
  end
  
  def destroy
    if session[:cas_user]
      session[:cas_user] = nil
      redirect_to "http://auth.tadnet.org/logout"
    else
      current_user_session.destroy if current_user_session
      flash[:notice] = "Logout successful!"
      redirect_back_or_default login_url
    end
  end

  def cas_login
    if current_user
      flash[:notice] = "Logged in with CAS"
    else
      flash[:warning] = "Problem logging in with CAS"
    end
    redirect_back_or_default '/'
  end
end
