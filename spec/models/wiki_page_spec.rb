require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPage do
  before(:each) do
    @wiki = Wiki.create!(:name => "tester wiki")
    @valid_attributes = {
      :title => "Test, test & test / test",
      :modifying_user_id => 1,
      :wiki_id => @wiki.id
    }    
  end

  it "should create a new instance given valid attributes" do
    WikiPage.create!(@valid_attributes)
  end

  it "should create and create tags" do
    wt = WikiTag.find_by_name "SomeTag A"
    wt.should be_nil
    wp = WikiPage.create!(:title => "With tags", :modifying_user_id => 1, :wiki_tags_string => "SomeTag A, Tag B",
      :wiki_id => @wiki.id)
    wt = WikiTag.find_by_name "SomeTag A"
    wt.should_not be_nil
    wp.wiki_tags.count.should == 2
  end

  it "should not create is tag already exists" do
    wt_count = WikiTag.count
    wp = WikiPage.create!(:title => "With tags", :modifying_user_id => 1, :wiki_tags_string => "SomeTag A",
      :wiki_id => @wiki.id)
    wt = WikiTag.find_by_name "SomeTag A"
    wt.should_not be_nil
    wt_count = WikiTag.count
    WikiPage.create!(:title => "Another with tags", :modifying_user_id => 1, :wiki_tags_string => "SomeTag A",
      :wiki_id => @wiki.id)
    wt_count.should == WikiTag.count
  end

  it "should create and more tags" do
    wt = WikiTag.find_by_name "SomeTag A"
    wt.should be_nil
    wp = WikiPage.create!(:title => "With tags", :modifying_user_id => 1, :wiki_tags_string => "A,B,C, ",
      :wiki_id => @wiki.id)
    wt = WikiTag.find_by_name "A"
    wt.should_not be_nil
    wp.wiki_tags.count.should == 3
  end

  it "should create a new comment when a new page is created" do
    wp = WikiPage.create!(:title => "easy", :modifying_user_id => 1, :wiki_id => @wiki.id)
    wc = WikiComment.find :last
    assert wc
    wc.body.should == "created a new page: <a href=\"/wikis/1/page/easy\" title=\"easy\">easy</a>"
  end

  it "should not create a new comment when a page is update in less than 30 minutes since last edit" do
    wp = WikiPage.create!(:title => "easy", :modifying_user_id => 1, :wiki_id => @wiki.id)
    wp = WikiPage.find wp.id
    wp.title = "Easily Updated"
    wp.should be_valid
    wp.save
    wc = WikiComment.find :last
    assert wc
    wc.body.should == "created a new page: <a href=\"/wikis/1/page/easy\" title=\"easy\">easy</a>"
  end

  it "should fail to create a new page if title already exists" do
    WikiPage.create!(:title => "Test Duplicate", :modifying_user_id => 1, :wiki_id => @wiki.id)
    wp = WikiPage.new(:title => "Test Duplicate", :modifying_user_id => 1, :wiki_id => @wiki.id)
    wp.should_not be_valid
    wp.errors.should_not be_empty
    wp.errors.full_messages.should_not be_empty
    wp.errors.full_messages.should include("Title has already been taken")
  end
end

# == Schema Information
#
# Table name: wiki_pages
#
#  id                 :integer         not null, primary key
#  title              :string(255)
#  url_title          :string(255)
#  modifying_user_id  :integer
#  body               :text
#  created_at         :datetime
#  updated_at         :datetime
#  version            :integer
#  started_editing_at :datetime
#  editing_user_id    :integer
#  wiki_id            :integer
#

