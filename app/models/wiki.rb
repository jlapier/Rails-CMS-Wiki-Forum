class Wiki < ActiveRecord::Base
  alias_attribute :title, :name
  has_many :wiki_pages
  has_many :wiki_comments
  has_many :wiki_tags

  default_scope order('position, name')
  after_destroy :fix_group_access

  private
  def fix_group_access
    UserGroup.all_fix_wiki_access
  end
end

# == Schema Information
#
# Table name: wikis
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

