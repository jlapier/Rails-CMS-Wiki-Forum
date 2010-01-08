# == Schema Information
# Schema version: 20100107232148
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
  validates_presence_of :name
  has_and_belongs_to_many :categories
  belongs_to :editing_user, :class_name => 'User', :foreign_key => 'editing_user_id'
  searchable_by :name, :body
  before_create :set_preview_only

  class << self
    def find_or_create_by_name(name)
      cp = find_by_name(name)
      cp || ContentPage.create( :name => name, :body => "<p>TO DO: edit this page</p>" )
    end

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
        categories = Category.find(:all, :order => order_string_from_sort_in_function(sort_order), :limit => limit)
        out = "<ul>\n"

        out += "<li><a href=\"/\">Home</a></li>\n" if use_homelink

        if categories.empty?
          out += "<li><em>No categories were found</em></li>\n"
        else
          out += categories.map { |cat|
            "<li><a href=\"/categories/#{cat.id}\">#{cat.name}</a></li>"
          }.join("\n")
        end

        out += "\n</ul>\n"
        out
      when "listpagesincategory"
        category = Category.find_by_name param
        out = "<ul>\n"

        out += "<li><a href=\"/\">Home</a></li>\n" if use_homelink
        
        if category
          pages = category.content_pages.find(:all, 
            :conditions => ['is_preview_only = ? AND (publish_on IS NULL OR publish_on <= ?)', false, Date.today],
            :order => order_string_from_sort_in_function(sort_order), :limit => limit)
          if pages.empty?
              out += "<li><em>No pages were found in the category: #{param}</em></li>\n"
          else
            out += pages.map { |page|
              "<li><a href=\"/content_pages/#{page.id}\">#{page.name}</a></li>"
            }.join("\n")
          end

          out += "\n</ul>\n"
          out
        else
          ""
        end
      when "treecategories"
        if param.blank?
          categories = Category.find(:all, :include => :content_pages,
            :order => order_string_from_sort_in_function(sort_order), :limit => limit)
        else
          cat_names = param.split(',').map(&:strip)
          categories = Category.find(:all, :conditions => ["name in (?)", cat_names],
            :include => :content_pages,
            :order => order_string_from_sort_in_function(sort_order), :limit => limit)
        end
        
        out = "<ul>\n"

        out += "<li><a href=\"/\">Home</a></li>\n" if use_homelink

        if categories.empty?
          out += "<li><em>No categories were found</em></li>\n"
        else
          out += categories.map { |cat|
            "<li><a href=\"/categories/#{cat.id}\">#{cat.name}</a>" +
              "<ul>" +
              cat.content_pages.map { |page|
                "<li><a href=\"/content_pages/#{page.id}\">#{page.name}</a></li>"
              }.join("\n") +
            "</ul></li>"
          }.join("\n")
        end

        out += "\n</ul>\n"
        out
      when "linkpage"
        page = ContentPage.find_by_name param

        if page
          "<a href=\"/content_pages/#{page.id}\">#{page.name}</a>"
        else
          "<em>No page found named: #{param}</em>"
        end
      when "linkcategory"
        category = Category.find_by_name param

        if category
          "<a href=\"/categories/#{category.id}\">#{category.name}</a>"
        else
          "<em>No category found named: #{param}</em>"
        end
      when "searchbox"
        # TODO make an option to include category dropdown
        <<-END
          <form action="/content_pages/search" method="get" name="site_search_box" id="site_search_box">
            <input type="text" name="q" size="20">
            <input type="submit" value="search">
          </form>
        END
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
