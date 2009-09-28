# == Schema Information
# Schema version: 20090922222035
#
# Table name: wiki_comments
#
#  id           :integer(4)    not null, primary key
#  wiki_page_id :integer(4)    
#  user_id      :integer(4)    
#  body         :text          
#  created_at   :datetime      
#  updated_at   :datetime      
#

class WikiComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki_page

  validates_presence_of :user_id, :wiki_page_id, :body
  validates_length_of :body, :minimum => 5
end
