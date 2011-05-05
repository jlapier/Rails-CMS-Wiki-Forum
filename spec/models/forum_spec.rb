require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Forum do
  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :description => "value for description",
      :position => 1,
      :moderator_only => false
    }
  end

  it "should create a new instance given valid attributes" do
    Forum.create!(@valid_attributes)
  end
  
  it "finds the most recent message post in its collection" do
    forum = Forum.create!(@valid_attributes)
    msg1 = forum.message_posts.create!({
      :subject => 'Subj 1',
      :body => 'Bod 1',
      :created_at => Date.new(2011, 5, 1),
      :user_id => 1
    })
    msg2 = forum.message_posts.create!({
      :subject => 'Subj 1',
      :body => 'Bod 1',
      :created_at => Date.current,
      :user_id => 1
    })
    forum.most_recent_post.should eq msg2
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

