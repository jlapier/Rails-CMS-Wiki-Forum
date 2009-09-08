# == Schema Information
# Schema version: 20090904211126
#
# Table name: forums
#
#  id                     :integer       not null, primary key
#  title                  :string(255)   
#  description            :text          
#  position               :integer       
#  moderator_only         :boolean       
#  newest_message_post_id :integer       
#  created_at             :datetime      
#  updated_at             :datetime      
# End Schema

class Forum < ActiveRecord::Base
  validates_presence_of :title
end
