require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    Category.create!(@valid_attributes)
  end

  it "should find or create a new instance given name" do
    name = "test for find or create"
    Category.find_by_name(name).should be_nil
    cat = Category.find_or_create_by_name(name)
    cat.should_not be_nil
    Category.find_by_name(name).should_not be_nil
    cat_again = Category.find_or_create_by_name(name)
    cat.should == cat_again
  end

  it "should have a parent" do
    par = Category.create!(:name => "parent cat")
    ch = Category.create!(:name => "child cat", :parent => par)
    ch.parent.should == par
    par.children.should == [ch]
  end
end


# == Schema Information
#
# Table name: categories
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  parent_id  :integer
#

