class UserGroupsController < ApplicationController
  before_filter :require_admin_user
  
  # GET /user_groups
  # GET /user_groups.xml
  def index
    @user_groups = UserGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_groups }
    end
  end

  # GET /user_groups/1
  # GET /user_groups/1.xml
  def show
    @user_group = UserGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_group }
    end
  end

  def emails

    respond_to do |format|
      format.html { redirect_to user_groups_url }
      format.js do
        user_groups = [UserGroup.find(params[:user_group_ids])].flatten
        render :json => user_groups.map(&:users).flatten.unique.map(&:email).to_json
      end
    end
  end

  # GET /user_groups/new
  # GET /user_groups/new.xml
  def new
    @user_group = UserGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_group }
    end
  end

  # GET /user_groups/1/edit
  def edit
    @user_group = UserGroup.find(params[:id])
  end

  # POST /user_groups
  # POST /user_groups.xml
  def create
    @user_group = UserGroup.new(params[:user_group])

    respond_to do |format|
      if @user_group.save
        flash[:notice] = "User group <em>#{@user_group.name}</em> created."
        format.html { redirect_to(@user_group) }
        format.xml  { render :xml => @user_group, :status => :created, :location => @user_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_groups/1
  # PUT /user_groups/1.xml
  def update
    @user_group = UserGroup.find(params[:id])

    respond_to do |format|
      if @user_group.update_attributes(params[:user_group])
        flash[:notice] = "User group <em>#{@user_group.name}</em> updated."
        format.html { redirect_to(@user_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.xml
  def destroy
    @user_group = UserGroup.find(params[:id])
    @user_group.destroy

    respond_to do |format|
      format.html { redirect_to(user_groups_url) }
      format.xml  { head :ok }
    end
  end

  def drop_user
    @user_group = UserGroup.find(params[:id])
    if @user_group.drop_users(params[:user_ids] || params[:user_id])
      flash[:notice] = "User(s) dropped from #{@user_group.name}."
    else
      flash[:warning] = "Failed to drop user(s) from #{@user_group.name}. (#{@user_group.errors.full_messages.join('; ')}"
    end
    redirect_to @user_group
  end

  def add_members
    @user_group = UserGroup.find(params[:id])
    @users_not_in_group = User.find(:all) - @user_group.users
  end

  def add_users
    @user_group = UserGroup.find(params[:id])
    @user_group.users += User.find(params[:user_ids])
    if @user_group.save
      flash[:notice] = "User(s) added to #{@user_group.name}."
    else
      flash[:warning] = "Failed to add user(s) to #{@user_group.name}. (#{@user_group.errors.full_messages.join('; ')}"
    end
    redirect_to @user_group
  end
end
