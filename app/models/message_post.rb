class MessagePost < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  belongs_to :thread, :class_name => 'MessagePost', :foreign_key => 'thread_id', :include => :user

  has_many :child_posts, :class_name => 'MessagePost', :foreign_key => 'thread_id', :include => :user, :dependent => :destroy

  validates_presence_of :subject, :body, :user_id

  searchable_by :subject, :body
  
  before_validation :fix_blank_subject

  acts_as_stripped :subject

  include ActionView::Helpers::DateHelper 

  class << self
    def search_forums(term)
      # uses search from "searchable_by"
      search term, :limit => 20, :order => "message_posts.updated_at DESC"
    end

    def per_page
      10
    end

    def last_page_number_for(conditions=nil)
      total = count :all, :conditions => conditions
      [((total - 1) / per_page) + 1, 1].max
    end
  end

  # only for threads
  def most_recent_reply
    @most_recent_reply ||= child_posts.find :first, :order => "message_posts.created_at DESC",
      :include => :user
  end

  def fix_blank_subject
    if subject.blank?
      if thread
        self.subject = "RE: #{thread.subject}"
      else
        self.subject = nil
      end
    end
  end

  def as_json(options = {})
    options ||= {}
    super(options.merge(
      :methods => [:poster, :forum_name, :post_time]))
  end

  def poster
    user.name
  end

  def forum_name
    forum.name
  end

  def post_time
		if (Time.now - created_at) > 2600000
			created_at.strftime "on %b %d, %Y"
		else
			time_ago_in_words(created_at) + " ago"
		end
    
  end
end

# == Schema Information
#
# Table name: message_posts
#
#  id            :integer         not null, primary key
#  subject       :string(255)
#  body          :text(16777215)
#  forum_id      :integer
#  parent_id     :integer
#  user_id       :integer
#  to_user_id    :integer
#  thread_id     :integer
#  replied_to_at :datetime
#  created_at    :datetime
#  updated_at    :datetime
#

