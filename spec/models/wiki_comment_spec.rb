require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiComment do
  before(:each) do

    Factory.define :wiki do |wiki|
      wiki.name "Some wiki"
    end
    @wiki = Factory(:wiki)

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
      wp.wiki @wiki
    end

    Factory.define :wiki_comment do |wc|
      wc.association :wiki_page, :factory => :wiki_page
      wc.association :user, :factory => :user
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

    @valid_attributes = {
      :wiki_page => Factory(:wiki_page), :user_id => 1, :body => "test comment"
    }
  end

  it "should create a new instance given valid attributes" do
    WikiComment.create!(@valid_attributes)
  end

  it "should get daily digest" do
    today_comment = Factory(:today)
    yesterday_comment = Factory(:yesterday)
    two_days_ago_comment = Factory(:two_days_ago)
    yesterday_comment.wiki.should == today_comment.wiki
    wiki = today_comment.wiki
    wcs = WikiComment.get_digest wiki
    wcs.should_not be_empty
    #wcs.size.should == 2
    assert wcs.first.new_record?
    wcs.first.title.should == "Daily Digest for #{Time.now.yesterday.strftime('%m/%d/%Y')}"
    wcs.first.body.should include(yesterday_comment.body)
    wcs.first.body.should_not include(today_comment.body)
    wcs.first.body.should_not include(two_days_ago_comment.body)
    assert wcs[1].new_record?
    wcs[1].title.should == "Daily Digest for #{Time.now.yesterday.yesterday.strftime('%m/%d/%Y')}"
    wcs[1].body.should include(two_days_ago_comment.body)
    wcs[1].body.should_not include(yesterday_comment.body)
    wcs[1].body.should_not include(today_comment.body)
  end

  it "should get weekly digest" do
    last_week_comment = Factory(:last_week)
    wiki = last_week_comment.wiki
    wcs = WikiComment.get_digest(wiki, :week)
    wcs.should_not be_empty
    assert wcs.first.new_record?
    wcs.first.title.should == "Weekly Digest for #{7.days.ago.beginning_of_week.strftime('%m/%d/%Y')}"
    wcs.first.body.should include(last_week_comment.body)
  end

  it "should make a title with comment on if regular comment" do
    wc = WikiComment.create!(@valid_attributes)
    wc.title.should match /Comment on: Cool Page \d/
  end

  it "should get to_html" do
    wc = WikiComment.create!(@valid_attributes)
    wc.to_html.should equal_without_whitespace("
      <p><span class=\"darkgray\">On <a href=\"/wikis/1/page/Cool_Page_1\" title=\"Cool Page 1\">Cool Page 1</a>,
      <strong>joe1</strong> said #{wc.created_at.strftime "on %b %d, %Y"}: &nbsp;</span>test comment</p>")
  end

  it "should get to_html without wiki page" do
    wc = WikiComment.create!(:user_id => 1, :body => "did something", :about_wiki_page => Factory(:wiki_page))
    wc.to_html.should equal_without_whitespace("
      <p><span class=\"darkgray\">#{wc.created_at.strftime "on %b %d, %Y"}
      <strong>joe1</strong></span>did something</p>")
  end

  it "should get to_html without user" do
    wc = WikiComment.create!(:user_id => 321321321, :body => "did something", :about_wiki_page => Factory(:wiki_page))
    wc.to_html.should equal_without_whitespace("
      <p><span class=\"darkgray\">#{wc.created_at.strftime "on %b %d, %Y"}
      <strong>someone</strong></span>did something</p>")
  end
end
