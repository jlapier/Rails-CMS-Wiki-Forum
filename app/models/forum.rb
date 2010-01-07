# == Schema Information
# Schema version: 20100107160119
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

  belongs_to :most_recent_post, :class_name => 'MessagePost', :foreign_key => :newest_message_post_id
  has_many :message_posts, :dependent => :destroy
end
