require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPage do
  before(:each) do
    @valid_attributes = {
      :title => "Test, test & test / test",
      :modifying_user_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    WikiPage.create!(@valid_attributes)
  end

  it "should create a new comment when a new page is created" do
    wp = WikiPage.create!(:title => "easy", :modifying_user_id => 1)
    wc = WikiComment.find :last
    assert wc
    wc.body.should == "created a new page: <a href=\"/wiki_page/easy\">easy</a>"
  end

  it "should not create a new comment when a page is update in less than 30 minutes since last edit" do
    wp = WikiPage.create!(:title => "easy", :modifying_user_id => 1)
    wp = WikiPage.find wp.id
    wp.title = "Easily Updated"
    wp.save
    wc = WikiComment.find :last
    assert wc
    wc.body.should == "created a new page: <a href=\"/wiki_page/easy\">easy</a>"
  end

  it "should fail to create a new page if title already exists" do
    WikiPage.create!(:title => "Test Duplicate", :modifying_user_id => 1)
    wp = WikiPage.new(:title => "Test Duplicate", :modifying_user_id => 1)
    wp.should_not be_valid
    wp.errors.should_not be_empty
    wp.errors.full_messages.should_not be_empty
    wp.errors.full_messages.should include("Title has already been taken")
  end
end
