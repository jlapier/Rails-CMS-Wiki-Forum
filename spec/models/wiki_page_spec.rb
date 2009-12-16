require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPage do
  before(:each) do
    @valid_attributes = {
      :title => "Test, test & test / test"
    }
  end

  it "should create a new instance given valid attributes" do
    WikiPage.create!(@valid_attributes)
  end

  it "should fail to create a new page if title already exists" do
    WikiPage.create!(:title => "Test Duplicate")
    wp = WikiPage.new(:title => "Test Duplicate")
    wp.should_not be_valid
    wp.errors.should_not be_empty
    wp.errors.full_messages.should_not be_empty
    wp.errors.full_messages.should include("Title has already been taken")
  end
end
