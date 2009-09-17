# = User - you know what it is


# == Schema Information
# Schema version: 20090908180148
#
# Table name: users
#
#  id                :integer       not null, primary key
#  created_at        :datetime      
#  updated_at        :datetime      
#  login             :string(255)   not null
#  email             :string(255)   not null
#  display_name      :string(255)   
#  crypted_password  :string(255)   not null
#  password_salt     :string(255)   not null
#  persistence_token :string(255)   not null
#  perishable_token  :string(255)   not null
#  login_count       :integer       default(0), not null
#  last_request_at   :datetime      
#  last_login_at     :datetime      
#  current_login_at  :datetime      
#  last_login_ip     :string(255)   
#  current_login_ip  :string(255)   
#  is_admin          :boolean       
# End Schema

class User < ActiveRecord::Base
  attr_protected :is_admin
  attr_protected :is_moderator
  has_many :message_posts
  
  acts_as_authentic

  # TODO define this
  def is_moderator_for_forum?(forum)
    false
  end


  def name
    display_name.blank? ? login : display_name
  end
end
