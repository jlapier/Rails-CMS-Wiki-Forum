class Forum < ActiveRecord::Base
  alias_attribute :name, :title
  
  validates_presence_of :title

  #belongs_to :most_recent_post, :class_name => 'MessagePost', :foreign_key => :newest_message_post_id
  has_many :message_posts, :dependent => :destroy

  default_scope order('position, title')
  after_destroy :fix_group_access

  def most_recent_post
    message_posts.order('created_at DESC').limit(1).first
  end

  def groups_with_access
    @groups_with_access ||= UserGroup.find_all_with_access_to(self)
  end

  def groups_with_read_access
    groups_with_access.select { |ug| ug.forums[self.id.to_s] == "read" }
  end

  def groups_with_write_access
    groups_with_access.select { |ug| ug.forums[self.id.to_s] == "write" }
  end

  def group_access=(ids_with_access)
    ids_with_access.each do |g_id, access|
      ug = UserGroup.find g_id
      ug.add_forum self, access
      ug.save
    end
  end

  private
  def fix_group_access
    UserGroup.all_fix_forum_access
  end
end

# == Schema Information
#
# Table name: forums
#
#  id                     :integer         not null, primary key
#  title                  :string(255)
#  description            :text
#  position               :integer
#  moderator_only         :boolean
#  newest_message_post_id :integer
#  created_at             :datetime
#  updated_at             :datetime
#

