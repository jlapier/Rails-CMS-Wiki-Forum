require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#@wiki = Factory(:wiki)
#@user = User.create :login => "joe", :email => "joe@dotcom.com",
#  :password => "supersecret", :password_confirmation => "supersecret"
  #Factory(:user)
#
#Factory.define :wiki_page do |wp|
#  wp.sequence(:title) {|n| "Cool Page #{n}" }
#  wp.body "<p>stuff in body</p>"
#end

Factory.define :wiki_comment do |wc|
  wc.looking_at_version 1
end

Factory.define :yesterday, :parent => :wiki_comment do |wc|
  wc.body "From yesterday"
  wc.created_at 1.day.ago
end

Factory.define :two_days_ago, :parent => :wiki_comment do |wc|
  wc.body "From two days ago"
  wc.looking_at_version 1
  wc.created_at 2.days.ago
end

Factory.define :today, :parent => :wiki_comment do |wc|
  wc.body "From today"
  wc.looking_at_version 1
  wc.created_at 0.days.ago
end

Factory.define :last_week, :parent => :wiki_comment do |wc|
  wc.body "From last week"
  wc.looking_at_version 1
  wc.created_at 7.days.ago
end


describe WikiComment do
  before(:each) do
    User.destroy_all
    @user = stub_model User, :id => 1, :name => 'joe1'
    @wiki = stub_model Wiki, :name => "Some wiki", :id => 1
    @wiki_page = stub_model WikiPage, :title => "Cool Page", :id => 1,
      :wiki_id => 1, :url_title => 'Cool_Page',
      :body => "<p>stuff in body</p>", :modifying_user => @user, :wiki => @wiki

    @valid_attributes = {
      :wiki_page => @wiki_page, :user => @user, :body => "test comment"
    }
  end

  it "should create a new instance given valid attributes" do
    WikiComment.create!(@valid_attributes)
  end

  it "should get daily digest" do
    today_comment = Factory(:today, :user => @user, :wiki_page => @wiki_page)
    yesterday_comment = Factory(:yesterday, :user => @user, :wiki_page => @wiki_page)
    two_days_ago_comment = Factory(:two_days_ago, :user => @user, :wiki_page => @wiki_page)
    
    wcs = WikiComment.get_digest @wiki
    wcs.should_not be_empty
    #wcs.size.should == 2
    assert wcs.first.new_record?
    wcs.first.title.should == "Daily Digest for #{Date.current.yesterday.strftime('%m/%d/%Y')}"
    wcs.first.body.should include(yesterday_comment.body)
    wcs.first.body.should_not include(today_comment.body)
    wcs.first.body.should_not include(two_days_ago_comment.body)
    assert wcs[1].new_record?
    wcs[1].title.should == "Daily Digest for #{Date.current.yesterday.yesterday.strftime('%m/%d/%Y')}"
    wcs[1].body.should include(two_days_ago_comment.body)
    wcs[1].body.should_not include(yesterday_comment.body)
    wcs[1].body.should_not include(today_comment.body)
  end

  it "should get weekly digest" do
    last_week_comment = Factory(:last_week, :user => @user, :wiki_page => @wiki_page)
    wcs = WikiComment.get_digest(@wiki, :week)
    wcs.should_not be_empty
    assert wcs.first.new_record?
    wcs.first.title.should == "Weekly Digest for #{7.days.ago.beginning_of_week.strftime('%m/%d/%Y')}"
    wcs.first.body.should include(last_week_comment.body)
  end

  it "should make a title with comment on if regular comment" do
    wc = WikiComment.create!(@valid_attributes)
    wc.title.should match /Comment on: Cool Page/
  end

  it "should get to_html" do
    wc = WikiComment.create!(@valid_attributes)
    wc.to_html.should equal_without_whitespace("
      <p><span class=\"darkgray\">On <a href=\"/wikis/1/page/Cool_Page\" title=\"Cool Page\">Cool Page</a>,
      <strong>joe1</strong> said #{wc.created_at.strftime "on %b %d, %Y"}: &nbsp;</span>test comment</p>")
  end

  it "should get to_html without wiki page" do
    wc = WikiComment.create!(:user => @user, :body => "did something", :about_wiki_page => @wiki_page)
    wc.to_html.should equal_without_whitespace("
      <p><span class=\"darkgray\">#{wc.created_at.strftime "on %b %d, %Y"}
      <strong>joe1</strong></span>did something</p>")
  end

  it "should get to_html without user" do
    wc = WikiComment.create!(:user_id => 321321321, :body => "did something", :about_wiki_page => @wiki_page)
    wc.to_html.should equal_without_whitespace("
      <p><span class=\"darkgray\">#{wc.created_at.strftime "on %b %d, %Y"}
      <strong>someone</strong></span>did something</p>")
  end
end

# == Schema Information
#
# Table name: wiki_comments
#
#  id                 :integer         not null, primary key
#  wiki_page_id       :integer
#  user_id            :integer
#  body               :text
#  looking_at_version :integer
#  created_at         :datetime
#  updated_at         :datetime
#  about_wiki_page_id :integer
#  wiki_id            :integer
#

