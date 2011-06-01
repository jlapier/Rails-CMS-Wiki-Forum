# comments.status has default of 'pending' from migration
module Blog
  class Comment < ActiveRecord::Base
    attr_accessible :post_id, :commenter_name, :commenter_email, :body
    
    validates_presence_of :commenter_name, :commenter_email,
      :if => Proc.new{|comment| comment.commenter_id.blank?}
    validates_presence_of :commenter_id,
      :if => Proc.new{|comment| comment.commenter_name.blank? and comment.commenter_email.blank?}
    validates_format_of :status, :with => /(pending|approved|spam)/
    validate :post_published
    
    belongs_to :post
    
    scope :approved, where(:status => "approved")
    scope :pending, where(:status => "pending")
  private
    def post_published
      errors.add(:body, "Comment cannot be saved.") unless post.published
    end
  public
    def commenter
      if commenter_id.blank?
        Commenter.new(commenter_name, commenter_email)
      else
        User.find commenter_id
      end
    end
    def approve
      self[:status] = "approved"
    end
    def approved?
      self[:status] == "approved"
    end
    def request_approval(current_user)
      if current_user and current_user.logged_in?
        approve
        self[:commenter_id] = current_user.id
      else
        self[:status] = "pending"
      end
    end
  end
  
  class Commenter
    attr_reader :name, :email
    
    def initialize(name, email)
      @name = name
      @email = email
    end
  end
end

# == Schema Information
#
# Table name: blog_comments
#
#  id              :integer         not null, primary key
#  post_id         :integer
#  status          :string(255)     default("pending")
#  commenter_id    :integer
#  commenter_email :string(255)
#  commenter_name  :string(255)
#  body            :text
#  created_at      :datetime
#  updated_at      :datetime
#

