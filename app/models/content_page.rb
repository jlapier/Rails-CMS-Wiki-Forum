# == Schema Information
# Schema version: 20100216214034
#
# Table name: content_pages
#
#  id                 :integer       not null, primary key
#  name               :string(255)   
#  body               :text          
#  special            :string(255)   
#  created_at         :datetime      
#  updated_at         :datetime      
#  is_preview_only    :boolean       
#  started_editing_at :datetime      
#  editing_user_id    :integer       
#  publish_on         :date          
# End Schema

class ContentPage < ActiveRecord::Base
  include HtmlGenerator
  
  validates_presence_of :name
  has_and_belongs_to_many :categories
  belongs_to :editing_user, :class_name => 'User', :foreign_key => 'editing_user_id'
  searchable_by :name, :body
  before_create :set_preview_only

  class << self
    def get_side_menu
      find(:first, :conditions => { :special => 'Side Menu'}) ||
        create( :special => 'Side Menu', :name => 'Side Menu', :is_preview_only => false,
          :body => "<h3>Menu</h3>\n[[ListCategories WithHome]]" )
    end

    def get_top_menu
      find(:first, :conditions => { :special => 'Top Menu'}) ||
        create( :special => 'Top Menu', :name => 'Top Menu', :is_preview_only => false,
          :body => "[[ListCategories]]" )
    end

    def get_front_page
      find(:first, :conditions => { :special => 'Front Page'}) ||
        create( :special => 'Front Page', :name => 'Welcome to the Site', :is_preview_only => false,
          :body => "<p>To do: edit this page</p>" )
    end


    # functions:
    #   ListCategories    // lists all categories
    #   ListPagesInCategory Some Kind of Category    // list all pages in the category called "Some Kind of Category"
    #   LinkPage Page Name  // links directly to the page specified
    #   LinkCategory Some Kind of Category    // links to the category index page
    def function(function_string)
      limit = nil
      function_string.gsub! "&nbsp;", " "
      function_name, param = function_string.split(' ', 2)
      if param
        use_homelink = param.downcase.include?("withhome")
        param.gsub!(/withhome/i, '')
        sort_match = param.downcase.match(/.*(sortby\S+).*/)
        if sort_match
          sort_order = sort_match[1]
          param.gsub!(/#{sort_order}/i, '')
        end

        limit_match = param.downcase.match(/.*limit=(\d+).*/)
        if limit_match
          limit = limit_match[1]
          param.gsub!(/limit=#{limit}/i, '')
        end
        param.strip!
      end

      case function_name.downcase
      when "listcategories"
        list_categories_to_html :order => order_string_from_sort_in_function(sort_order), :limit => limit,
          :use_homelink => use_homelink
      when "listpagesincategory"
        list_pages_in_category_to_html :category_name => param, :use_homelink => use_homelink,
          :order => order_string_from_sort_in_function(sort_order), :limit => limit
      when "treecategories"
        tree_categories_to_html :category_names => param.split(',').map(&:strip),
          :use_homelink => use_homelink,
          :order => order_string_from_sort_in_function(sort_order), :limit => limit
      when "linkpage"
        link_page_to_html param
      when "linkcategory"
        link_category_to_html param
      when "searchbox"
        search_box_to_html
      else
        "<em>Unknown function: #{function_name}</em>"
      end

    end

    private
    def order_string_from_sort_in_function(order_func)
      case order_func
      when 'sortbydate'
        'publish_on ASC'
      when 'sortbydatereverse'
        'publish_on DESC'
      when 'sortbyalpha'
        'name ASC'
      when 'sortbyalphareverse'
        'name DESC'
      else
        'name ASC'
      end
    end
  end

  def body_for_display
    main = (body || '').gsub( /(\[\[([^\]]*)\]\])/ ) { |s| ContentPage.function($2) }
    if is_preview_only?
      main += '<p><em class="highlight">This page is a draft and will not be visible to public viewers.</em></p>'
    end
    main
  end

  def ready_for_publishing?
    !is_preview_only? and (publish_on.blank? or publish_on <= Date.today)
  end


  private

  def set_preview_only
    self.is_preview_only = true if is_preview_only.nil?
  end
end
