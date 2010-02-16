require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiTag do
  before(:each) do
    @valid_attributes = {
      :name => "test tag", :wiki_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    WikiTag.create!(@valid_attributes)
  end
end
