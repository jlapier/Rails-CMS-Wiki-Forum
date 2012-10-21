# = User - you know what it is
# has a special field called 'user defined fields' - should be a hash
# a SiteSetting can be used to set up those fields

class User < ActiveRecord::Base
  validates_presence_of :login, :email

  attr_protected :is_admin
  attr_protected :is_moderator
  has_many :message_posts
  has_and_belongs_to_many :user_groups
  before_create :make_admin_if_first_user
  before_save :to_i_group_ids

  serialize :user_defined_fields
  serialize :requested_user_group_ids, Array

  acts_as_authentic

  after_initialize :blank_fields
  
  class << self
    def find_admins
      find :all, :conditions => { :is_admin => true }
    end

    # overwrite default AuthLogic behavior - allow users to log in with either login or email
    def find_by_smart_case_login_field(login)
      if login =~ Authlogic::Regex.email
        find_with_case(email_field, login, validates_uniqueness_of_email_field_options[:case_sensitive] != false)
      else
        find_with_case(login_field, login, validates_uniqueness_of_login_field_options[:case_sensitive] != false)
      end
    end
  end

  def blank_fields
    self.user_defined_fields ||= {}
    self.requested_user_group_ids ||= []
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

  def full_name; fullname; end

  # provide a string describing the access required,
  # returns 'read' or 'write' or nil (highest available)
  def group_access(wiki_or_forum)
    if wiki_or_forum.is_a?(Forum)
      user_groups.map {|g| g.grants_access_to_forum?(wiki_or_forum.id) }.compact.sort_by {|t| ['write', 'read'].index t }.first
    else
      user_groups.map {|g| g.grants_access_to_wiki?(wiki_or_forum.id) }.compact.sort_by {|t| ['write', 'read'].index t }.first
    end
  end

  def has_read_access_to?(wiki_or_forum)
    ['write', 'read'].include? group_access(wiki_or_forum)
  end

  def has_write_access_to?(wiki_or_forum)
    group_access(wiki_or_forum) == 'write'
  end

  def has_access_to_any_wikis?
    user_groups.any? { |g| !g.wikis.empty? }
  end

  def wikis
    @wikis ||= Wiki.find(user_groups.map { |g| g.wikis.keys }.flatten.uniq)
  end

  def has_access_to_any_forums?
    user_groups.any? { |g| !g.forums.empty? }
  end

  def forums
    @forums ||=  Forum.find(user_groups.map { |g| g.forums.keys }.flatten.uniq)
  end
  
  def following_posts
   return self.message_posts.find :all, :conditions=>'to_user_id = 1'
  end
  
  def deliver_password_reset_instructions!
    # authlogic provides this:
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def requested_user_groups
    @requested_user_groups ||= requested_user_group_ids.map { |g_id| 
      UserGroup.find(:first, :conditions => { :id => g_id }) }.compact
  end

  # I don't know how else to put this, so I'll put it like so:
  # 1 -> user requested to be in this group and is in it
  # 0 -> user did not request, but is in it anyway
  # -1 -> user requested membership but does not have it
  def group_status(group)
    if user_groups.include?(group)
      if requested_user_groups.include?(group)
        1
      else
        0
      end
    else
      -1
    end
  end

  private
  def make_admin_if_first_user
    self.is_admin = true if User.count == 0
  end

  def to_i_group_ids
    self.requested_user_group_ids = self.requested_user_group_ids.map(&:to_i)
  end
end


User.partial_updates = false

# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  created_at               :datetime
#  updated_at               :datetime
#  login                    :string(255)     not null
#  email                    :string(255)     not null
#  crypted_password         :string(255)     not null
#  password_salt            :string(255)     not null
#  persistence_token        :string(255)     not null
#  perishable_token         :string(255)     not null
#  login_count              :integer         default(0), not null
#  last_request_at          :datetime
#  last_login_at            :datetime
#  current_login_at         :datetime
#  last_login_ip            :string(255)
#  current_login_ip         :string(255)
#  is_admin                 :boolean
#  first_name               :string(255)
#  last_name                :string(255)
#  user_defined_fields      :text
#  requested_user_group_ids :string(255)
#  single_access_token      :string(255)
#

