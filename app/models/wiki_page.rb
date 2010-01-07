# == Schema Information
# Schema version: 20100107160119
#
# Table name: wiki_pages
#
#  id                :integer       not null, primary key
#  title             :string(255)   
#  url_title         :string(255)   
#  modifying_user_id :integer       
#  body              :text          
#  created_at        :datetime      
#  updated_at        :datetime      
#  version           :integer       
# End Schema

class WikiPage < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  belongs_to :modifying_user, :foreign_key => "modifying_user_id", :class_name => "User"

  searchable_by :title, :body

  validates_presence_of :title, :url_title, :modifying_user_id
  
  has_and_belongs_to_many :wiki_tags
  has_many :wiki_comments, :dependent => :destroy
  
  before_validation :set_url_title

  validates_uniqueness_of :title
#  def validate
#    if id and WikiPage.count( :conditions => ["title = ? AND id != ?", title, id] ) > 0
#      errors.add :title, "has been taken (<a href=\"/wiki/#{url_title}/\">#{title}</a>)"
#    elsif id.nil? and WikiPage.count( :conditions => ["title = ?", title] ) > 0
#      errors.add :title, "has been taken (<a href=\"/wiki/#{url_title}/\">#{title}</a>)"
#    end
#  end
  
  after_save :save_tags
  
  acts_as_versioned do
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper

    def modifying_user
      modifying_user_id ? User.find(modifying_user_id) : nil
    end
    
    # sub out [[wiki-words]] with links to pages
    def body_for_display
      (body || '').gsub( /(#REDIRECT \[\[([^\]]*)\]\])/ ) { |s| WikiPage.wiki_redirect_to($2) }.
        gsub( /(\[\[([^\]]*)\]\])/ ) { |s| WikiPage.wiki_link_to($2) }
    end

    def my_link_to
      link_to(title, "/wiki/#{url_title}", :title => title)
    end
  end
  
  class << self
    def wiki_link_to(title)
      wp = find_by_title title
      if wp
        wp.my_link_to
      else
        link_to(title, "/wiki/#{title}", :title => "Click to create page: #{title}", 
          :class => 'wiki_page_not_found')
      end
    end
    
    def wiki_redirect_to(title)
      wp = find_by_title title
      if wp
        "Redirecting to: #{wp.my_link_to}..." +
          javascript_tag("setTimeout(window.location.href = '/wiki/#{wp.url_title}', 2000)")
      else
        link_to(title, "/wiki/#{title}", :title => "Click to create page: #{title}", 
          :class => 'wiki_page_not_found')
      end
    end
    
    # find anything that has this chunk of text in the title or the body
    def find_like(chunk)
      results = find :all, :conditions => [ "title like ? or body like ?", "%#{chunk}%", "%#{chunk}%"],
        :limit => 20, :select => "id, url_title, title, updated_at", 
        :order => sanitize_sql_array(["INSTR(title, ?), INSTR(body, ?)", "%#{chunk}%", "%#{chunk}%"])
      
      # sort by having a title with the closest match to the chunk
      results.sort_by { |wp| wp.title.gsub(chunk, '').size }
    end

    def find_or_create_by_title(title)
      wp = find_by_title(title)
      wp || WikiPage.create( :title => title, :body => "<p>TO DO: edit this page by going to: [[#{title}]]</p>" )
    end
  end
  
  def wiki_tags_string
    wiki_tags.map(&:name).join(", ")
  end
  
  def wiki_tags_string=(str)
    self.wiki_tags.clear
    str.split(",").each do |tag_name|
      tag_name.strip!
      wt = WikiTag.find_or_create_by_name tag_name
      self.wiki_tags << wt
      self.wiki_tags.uniq!
    end
  end

  def who_has_edited
    versions.map(&:modifying_user)
  end

  
  private
  def set_url_title
    self.url_title = title.unspace.gsub("/", "---").gsub("&", "((and))").gsub('.', 'DOT') if title
  end
  
  def save_tags
    
  end
end
