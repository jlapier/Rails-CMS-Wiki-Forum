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

  validates_presence_of :user_id, :wiki_page_id, :body
  validates_length_of :body, :minimum => 5
end
