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

