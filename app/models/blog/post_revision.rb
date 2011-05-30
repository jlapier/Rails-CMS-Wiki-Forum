module Blog
  class PostRevision < ActiveRecord::Base
    include DeletableInstanceMethods
    
    acts_as_revision :revisable_class_name => "Blog::Post"
    
    belongs_to :author, :class_name => 'User'
    belongs_to :modifying_user, :class_name => 'User'
    belongs_to :category
  end
end
# == Schema Information
#
# Table name: blog_posts
#
#  id                         :integer         not null, primary key
#  author_id                  :integer
#  category_id                :integer
#  editing_user_id            :integer
#  modifying_user_id          :integer
#  title                      :string(255)
#  body                       :text
#  published                  :boolean         default(FALSE)
#  started_editing_at         :datetime
#  created_at                 :datetime
#  updated_at                 :datetime
#  revisable_original_id      :integer
#  revisable_branched_from_id :integer
#  revisable_number           :integer         default(0)
#  revisable_name             :string(255)
#  revisable_type             :string(255)
#  revisable_current_at       :datetime
#  revisable_revised_at       :datetime
#  revisable_deleted_at       :datetime
#  revisable_is_current       :boolean         default(TRUE)
#

