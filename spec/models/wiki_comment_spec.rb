require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiComment do
  before(:each) do
    @valid_attributes = {
      :wiki_page_id => 1, :user_id => 1, :body => "test comment"
    }
  end

  it "should create a new instance given valid attributes" do
    WikiComment.create!(@valid_attributes)
  end
end
