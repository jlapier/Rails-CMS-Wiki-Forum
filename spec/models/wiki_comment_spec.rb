require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Factory.define :user do |u|
  u.sequence(:login) {|n| "joe#{n}" }
  u.sequence(:email) {|n| "joe#{n}@dotcom.com" }
  u.password "supersecret"
  u.password_confirmation { |user| user.password }
end

Factory.define :wiki_page do |wp|
  wp.sequence(:title) {|n| "Cool Page #{n}" }
  wp.body "<p>stuff in body</p>"
  wp.association :modifying_user, :factory => :user
end

Factory.define :yesterday, :class => WikiComment do |wc|
  wc.body "From yesterday"
  wc.association :wiki_page, :factory => :wiki_page
  wc.association :user, :factory => :user
  wc.looking_at_version 1
  wc.created_at Time.now.yesterday
end

Factory.define :two_days_ago, :class => WikiComment do |wc|
  wc.body "From two days ago"
  wc.association :wiki_page, :factory => :wiki_page
  wc.association :user, :factory => :user
  wc.looking_at_version 1
  wc.created_at 2.days.ago
end

Factory.define :today, :class => WikiComment do |wc|
  wc.body "From today"
  wc.association :wiki_page, :factory => :wiki_page
  wc.association :user, :factory => :user
  wc.looking_at_version 1
  wc.created_at Time.now
end

Factory.define :last_week, :class => WikiComment do |wc|
  wc.body "From last week"
  wc.association :wiki_page, :factory => :wiki_page
  wc.association :user, :factory => :user
  wc.looking_at_version 1
  wc.created_at 7.days.ago
end

describe WikiComment do
  before(:each) do
    @valid_attributes = {
      :wiki_page_id => 1, :user_id => 1, :body => "test comment"
    }
  end

  it "should create a new instance given valid attributes" do
    WikiComment.create!(@valid_attributes)
  end

  it "should get daily digest" do
    today_comment = Factory(:today)
    yesterday_comment = Factory(:yesterday)
    two_days_ago_comment = Factory(:two_days_ago)
    wcs = WikiComment.get_digest
    wcs.should_not be_empty
    assert wcs.first.new_record?
    wcs.first.title.should == "Daily Digest for #{Time.now.yesterday.strftime('%m/%d/%Y')}"
    wcs.first.body.should include(yesterday_comment.body)
    wcs.first.body.should_not include(today_comment.body)
    wcs.first.body.should_not include(two_days_ago_comment.body)
    assert wcs[1].new_record?
    wcs[1].title.should == "Daily Digest for #{2.days.ago.strftime('%m/%d/%Y')}"
    wcs[1].body.should include(two_days_ago_comment.body)
    wcs[1].body.should_not include(yesterday_comment.body)
    wcs[1].body.should_not include(today_comment.body)
  end

  it "should get weekly digest" do
    last_week_comment = Factory(:last_week)
    wcs = WikiComment.get_digest(:week)
    wcs.should_not be_empty
    assert wcs.first.new_record?
    wcs.first.title.should == "Weekly Digest for #{7.days.ago.beginning_of_week.strftime('%m/%d/%Y')}"
    wcs.first.body.should include(last_week_comment.body)
  end
end
