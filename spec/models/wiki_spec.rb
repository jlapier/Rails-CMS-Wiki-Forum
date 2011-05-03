require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Wiki do
  before(:each) do
    @valid_attributes = {
      :name => "Test wiki"
    }
  end

  it "should create a new instance given valid attributes" do
    Wiki.create!(@valid_attributes)
  end
end
# == Schema Information
#
# Table name: wikis
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

