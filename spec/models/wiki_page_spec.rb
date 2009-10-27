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
end
