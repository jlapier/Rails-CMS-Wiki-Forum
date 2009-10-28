require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContentPage do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :body => "value for body"
    }
  end

  it "should create a new instance given valid attributes" do
    ContentPage.create!(@valid_attributes)
  end
end
