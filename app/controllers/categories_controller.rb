class CategoriesController < ApplicationController
  before_filter :require_admin_user, :except => [:home, :index, :show]

  # GET /categories
  # GET /categories.xml
  def index
    @category = Category.new
    @categories = Category.all
    @root_categories = @categories.select { |cat| cat.parent_id.nil? }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])
    if @category.redirect_to_content_page and params[:no_redirect].blank?
      redirect_to @category.redirect_to_content_page
    end
  end

  def edit
    @category = Category.find(params[:id])
    @categories = Category.where(["id != ?", params[:id]])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        flash[:notice] = "Category <em>#{@category.name}</em> was successfully created."
        format.html { redirect_to categories_path }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to(category_path(@category, :no_redirect => 1)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end


  def sort
    categories = Category.find(params['cat'])
    categories.each do |cat|
      cat.position = params['cat'].index(cat.id.to_s) + 1
      cat.save
    end
    render :nothing => true
  end
end
