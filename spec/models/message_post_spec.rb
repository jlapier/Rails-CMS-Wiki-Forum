require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagePost do
  before(:each) do
    @valid_attributes = {
      :subject => "value for subject",
      :body => "value for body",
      :forum_id => 1,
      :parent_id => 1,
      :user_id => 1,
      :to_user_id => 1,
      :thread_id => 1,
      :replied_to_at => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    MessagePost.create!(@valid_attributes)
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

