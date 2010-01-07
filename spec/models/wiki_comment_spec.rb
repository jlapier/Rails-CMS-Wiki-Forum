require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Factory.define :user do |u|
  u.sequence(:login) {|n| "joe#{n}" }
  u.sequence(:email) {|n| "joe#{n}@dotcom.com" }
  u.password "supersecret"
  u.password_confirmation { |user| user.password }
end

Factory.define :wiki_page do |wp|
  wp.title "Cool Page"
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
    yesterday_comment = Factory(:yesterday)
    wcs = WikiComment.get_digest
    wcs.should_not be_empty
    wcs.should include(yesterday_comment)
  end
end
