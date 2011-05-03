module Blog
  class Post < ActiveRecord::Base
    validates_presence_of :author_id, :title
    validates_uniqueness_of :title
    
    belongs_to :author, :class_name => 'User'
    belongs_to :editing_user, :class_name => 'User'
    belongs_to :modifying_user, :class_name => 'User'
    belongs_to :category
  end
end


# == Schema Information
#
# Table name: blog_posts
#
#  id                 :integer         not null, primary key
#  author_id          :integer
#  category_id        :integer
#  editing_user_id    :integer
#  modifying_user_id  :integer
#  title              :string(255)
#  body               :text
#  published          :boolean         default(FALSE)
#  started_editing_at :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

