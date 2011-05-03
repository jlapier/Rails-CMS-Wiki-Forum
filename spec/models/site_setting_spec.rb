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

  it "should write a numerical setting and then read it" do
    num = 29
    name = "Some number"
    assert SiteSetting.write_setting(name, num)
    read_val = SiteSetting.read_setting(name)
    read_val.should == num
    read_val.should be_kind_of(Numeric)
  end

  it "should write a string setting and then read it" do
    str = "Blah blah"
    name = "Some number"
    assert SiteSetting.write_setting(name, str)
    read_val = SiteSetting.read_setting(name)
    read_val.should == str
    read_val.should be_kind_of(String)
  end

  it "should write a text setting and then read it" do
    str = "ten chars"*30
    name = "Some number"
    assert SiteSetting.write_setting(name, str)
    read_val = SiteSetting.read_setting(name)
    read_val.should == str
    read_val.should be_kind_of(String)
  end

  it "should read or write a default" do
    n = "A setting with a default value"
    v = "my default value"
    read_val1 = SiteSetting.read_or_write_default_setting(n, v)
    read_val1.should == v
    read_val2 = SiteSetting.read_setting(n)
    read_val2.should == v
    assert SiteSetting.write_setting(n, "override default")
    read_val3 = SiteSetting.read_or_write_default_setting(n, v)
    read_val3.should == "override default"
  end
end

# == Schema Information
#
# Table name: site_settings
#
#  id                   :integer         not null, primary key
#  setting_name         :string(255)
#  setting_string_value :string(255)
#  setting_text_value   :text
#  setting_number_value :integer
#  yamled               :boolean
#  created_at           :datetime
#  updated_at           :datetime
#

