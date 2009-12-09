# = User - you know what it is
# has a special field called 'user defined fields' - should be a hash
# a SiteSetting can be used to set up those fields

# == Schema Information
# Schema version: 20091202222916
#
# Table name: users
#
#  id                  :integer       not null, primary key
#  created_at          :datetime      
#  updated_at          :datetime      
#  login               :string(255)   not null
#  email               :string(255)   not null
#  crypted_password    :string(255)   not null
#  password_salt       :string(255)   not null
#  persistence_token   :string(255)   not null
#  perishable_token    :string(255)   not null
#  login_count         :integer       default(0), not null
#  last_request_at     :datetime      
#  last_login_at       :datetime      
#  current_login_at    :datetime      
#  last_login_ip       :string(255)   
#  current_login_ip    :string(255)   
#  is_admin            :boolean       
#  first_name          :string(255)   
#  last_name           :string(255)   
#  user_defined_fields :text          
# End Schema

class User < ActiveRecord::Base
  attr_protected :is_admin
  attr_protected :is_moderator
  has_many :message_posts
  has_and_belongs_to_many :user_groups
  before_create :make_admin_if_first_user

  serialize :user_defined_fields

  acts_as_authentic

  def after_initialize
    self.user_defined_fields ||= {}
  end

  # TODO define this
  def is_moderator_for_forum?(forum)
    false
  end


  def name
    first_name.blank? ? login : first_name
  end

  def fullname
    first_name.blank? ? login : "#{first_name} #{last_name}"
  end

  def has_access_to?(component)
    user_groups.any? { |ug| ug.access_string =~ /#{component}/i }
  end

  def has_group_access?(access_required)
    user_groups.any? {|g| g.grants_access_to?(access_required) }
  end

  private
  def make_admin_if_first_user
    self.is_admin = true if User.count == 0
  end
end


User.partial_updates = false
