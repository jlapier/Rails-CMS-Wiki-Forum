# == Schema Information
# Schema version: 20100125191432
#
# Table name: wiki_comments
#
#  id                 :integer       not null, primary key
#  wiki_page_id       :integer       
#  user_id            :integer       
#  body               :text          
#  looking_at_version :integer       
#  created_at         :datetime      
#  updated_at         :datetime      
#  about_wiki_page_id :integer       
#  wiki_id            :integer       
# End Schema

class WikiComment < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  
  belongs_to :user
  belongs_to :wiki_page
  belongs_to :wiki
  belongs_to :about_wiki_page, :class_name => 'WikiPage'

  validates_presence_of :user_id, :body
  validates_length_of :body, :minimum => 5

  attr_accessor :title

  before_save :set_wiki_id

  def validate
    unless wiki_page_id or about_wiki_page_id
      errors.add(:base, "must be made on a wiki page or about a wiki page")
    end
  end

  class << self
    def create_chatter_about_page(page)
      current = page.versions.latest
      if current.version == 1
        create! :user_id => page.modifying_user_id, :about_wiki_page_id => page.id,
          :body => "created a new page: #{current.my_link_to}"
      else
        # don't create an update unless it's been 30 minutes since the last version
        prev = current.previous
        if prev and (current.updated_at - prev.updated_at) > 30.minutes
          create! :user_id => page.modifying_user_id, :about_wiki_page_id => page.id,
            :body => "updated a page: #{current.my_link_to}"
        end
      end
    end

    # get digest by either 'day' or 'week'
    def get_digest(to_group_by = 'day')
      to_group_by = to_group_by.to_sym
      up_to_date = to_group_by == :day ? Time.now.beginning_of_day : Time.now.beginning_of_week
      all_comments = WikiComment.find :all, :include => :user, :limit => 40, :order => "created_at DESC",
        :conditions => ["created_at < ?", up_to_date]
      fake_comments = []
      all_comments.group_by(&to_group_by).each do |day, comments|
        fake_comments << WikiComment.new( :created_at => day,
          :title => "#{to_group_by == :day ? 'Daily' : 'Weekly'} Digest for #{day.strftime('%m/%d/%Y')}",
          :body => comments.map(&:to_html).join("\n"),
          :user_id => comments.first.user_id )
      end
      fake_comments
    end
  end

  # used for feeds
  def title
    return @title if @title
    if about_wiki_page_id
      @title = "Page changed: #{about_wiki_page.title}"
    elsif wiki_page_id
      @title = "Comment on: #{wiki_page.title}"
    else
      @title = body
    end
  end


  # used to make grouping easier: day this comment was created
  def day
    created_at.beginning_of_day
  end

  # used to make grouping easier: week this comment was created
  def week
    created_at.beginning_of_week
  end

  def to_html
    out = "<p>"
    if wiki_page
      out << "<span class=\"darkgray\">" +
              "On #{wiki_page.my_link_to}, <strong>#{user.name}</strong> said #{created_at.strftime "on %b %d, %Y"}:" +
              " &nbsp;</span>"
    else
      out << "<span class=\"darkgray\">" +
              "#{created_at.strftime "on %b %d, %Y"} <strong>#{user.name}</strong></span> "
    end
    out << textilize_without_paragraph(body)
    out << "</p>"
    out
  end

  private

  def set_wiki_id
    self.wiki_id = (wiki_page || about_wiki_page).wiki_id
  end
end
