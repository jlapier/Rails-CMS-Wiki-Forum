module Blog
  class Post < ActiveRecord::Base    
    attr_accessible :category, :category_id, :title, :body
    
    validates_presence_of :author_id, :title
    validates_uniqueness_of :title, :scope => :revisable_original_id
    
    belongs_to :author, :class_name => 'User'
    belongs_to :editing_user, :class_name => 'User'
    belongs_to :modifying_user, :class_name => 'User'
    belongs_to :category
    has_many :comments
    
    scope :published, where(:published => true)
    scope :draft, where(:published => false)
    
    acts_as_revisable({
      :revision_class_name => "Blog::PostRevision",
      :except => [:category_id, :editing_user_id, :modifying_user_id,
                 :published, :started_editing_at, :created_at, :updated_at],
      :on_delete => :revise
    })
  public
    def name
      title
    end
    def toggle_published
      self.published = self.published ? false : true
      self.save(:without_revision => true)
    end
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

