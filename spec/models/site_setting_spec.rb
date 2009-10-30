require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SiteSetting do
  before(:each) do
    @valid_attributes = {
      :setting_name => "value for setting_name",
      :setting_string_value => "value for setting_string_value",
      :setting_text_value => "value for setting_text_value",
      :setting_number_value => 1,
      :yamled => false
    }
  end

  it "should create a new instance given valid attributes" do
    SiteSetting.create!(@valid_attributes)
  end
end
