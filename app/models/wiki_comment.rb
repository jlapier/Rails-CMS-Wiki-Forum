# == Schema Information
# Schema version: 20091202222916
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
# End Schema

class WikiComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki_page

  validates_presence_of :user_id, :body
  validates_length_of :body, :minimum => 5

  class << self
    def create_chatter_about_page(page)
      current = page.versions.latest
      if current.version == 1
        create! :user_id => page.modifying_user_id,
          :body => "created a new page: <a href=\"/wiki/#{current.url_title}\">#{current.title}</a>"
      else
        # don't create an update unless it's been 30 minutes since the last version
        prev = current.previous
        if prev and (current.updated_at - prev.updated_at) > 30.minutes
          create! :user_id => page.modifying_user_id,
            :body => "updated a page: <a href=\"/wiki/#{current.url_title}\">#{current.title}</a>"
        end
      end
    end
  end
end
