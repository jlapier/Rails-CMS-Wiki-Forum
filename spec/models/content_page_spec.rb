require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContentPage do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :body => "value for body"
    }
    @mock_category = Category.new :name => 'A Test Category'
    @mock_category.stub!(:id).and_return(1)
    @mock_content_page = ContentPage.new :name => 'Page ABC', :publish_on => 10.days.ago, :is_preview_only => false
    @mock_content_page.stub!(:id).and_return(123)
  end

  it "should create a new instance given valid attributes" do
    cp = ContentPage.create!(@valid_attributes)
    assert cp.is_preview_only?
    assert !cp.ready_for_publishing?
    cp.body_for_display.should match /This page is a draft/
    cp.is_preview_only = false
    cp.publish_on = 10.days.ago
    cp.save!
    cp.reload
    assert !cp.is_preview_only?
    assert cp.ready_for_publishing?
    cp.body_for_display.should_not match /This page is a draft/
  end

  it "should get new front page" do
    cp = ContentPage.get_front_page
    cp.should_not be_nil
    # new front page starts with this generic name
    cp.name.should == 'Welcome to the Site'
    cp_again = ContentPage.get_front_page
    cp.should == cp_again
  end

  it "should create a new instance given valid attributes and override the preview for some pages" do
    cp = ContentPage.create!(@valid_attributes.merge(:is_preview_only => false))
    assert !cp.is_preview_only?
    assert cp.ready_for_publishing?
  end

  it "should generate HTML from function ListCategories" do
    Category.should_receive(:find).with(:all, {:order=>"name ASC", :limit => nil}).and_return([@mock_category])
    expected = "<ul>" +
      "<li><a href=\"/categories/1\">A Test Category</a></li>" +
      "</ul>"
    ContentPage.function('ListCategories').should == expected
  end

  it "should generate HTML from function ListCategories WithHome" do
    Category.should_receive(:find).with(:all, {:order=>"name ASC", :limit => nil}).and_return([@mock_category])
    expected = "<ul>" +
      "<li><a href=\"/\">Home</a></li>" +
      "<li><a href=\"/categories/1\">A Test Category</a></li>" +
      "</ul>"
    ContentPage.function('ListCategories WithHome').should == expected
  end

  it "should generate HTML from function ListPagesInCategory A Test Category" do
    mock_association_proxy = [@mock_content_page]
    mock_association_proxy.stub!(:find).and_return(mock_association_proxy)
    @mock_category.stub!(:content_pages).and_return(mock_association_proxy)
    Category.should_receive(:find_by_name).with('A Test Category').and_return(@mock_category)

    expected = "<ul>" +
      "<li><a href=\"/content_pages/123\">Page ABC</a></li>" + 
      "</ul>"
    ContentPage.function('ListPagesInCategory A Test Category').should == expected
  end

  it "should generate HTML from function ListPagesInCategory A Test Category WithHome" do
    mock_association_proxy = [@mock_content_page]
    mock_association_proxy.stub!(:find).and_return(mock_association_proxy)
    @mock_category.stub!(:content_pages).and_return(mock_association_proxy)
    Category.should_receive(:find_by_name).with('A Test Category').and_return(@mock_category)

    expected = "<ul>" +
      "<li><a href=\"/\">Home</a></li>" +
      "<li><a href=\"/content_pages/123\">Page ABC</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory A Test Category WithHome').should == expected
  end
end

describe "content page search functions" do
  before(:each) do
    category_1 = Category.create! :name => "Testing Category One"
    category_2 = Category.create! :name => "Testing Category Two"
    @cp1 = ContentPage.create! :name => "Page A", :body => "AAAA"
    @cp1.categories << category_1
    @cp1.save!
    @cp2 = ContentPage.create! :name => "Page B", :body => "BBBB"
    @cp2.categories << category_1
    @cp2.categories << category_2
    @cp2.save!
  end

  it "should find by page name" do
    cps = ContentPage.search "Page"
    cps.should == [@cp1, @cp2]
    cps = ContentPage.search '"Page A"'
    cps.should == [@cp1]
  end

  it "should find by page body" do
    cps = ContentPage.search "AAA"
    cps.should == [@cp1]
  end

  it "should find by category" do
    cps = ContentPage.search "Testing"
    cps.should == [@cp1, @cp2]
    cps = ContentPage.search '"Category One"'
    cps.should == [@cp1, @cp2]
    cps = ContentPage.search '"Category Two"'
    cps.should == [@cp2]
  end
end

describe "content page ordered listings" do
  before(:each) do
    real_category = Category.create! :name => "Testing a Real Cat"
    @cp1 = ContentPage.create! :name => 'Page A from 9 days ago', :publish_on => 9.days.ago, :is_preview_only => false
    @cp2 = ContentPage.create! :name => 'Page B from 5 days ago', :publish_on => 5.days.ago, :is_preview_only => false
    @cp3 = ContentPage.create! :name => 'Page C from 7 days ago', :publish_on => 7.days.ago, :is_preview_only => false
    [@cp1, @cp2, @cp3].each do |cp|
      assert cp.categories << real_category
      assert cp.save
    end
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByDate" do
    expected = "<ul>" +
      "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory Testing a Real Cat SortByDate').should == expected
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByDateReverse" do
    expected = "<ul>" +
      "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory Testing a Real Cat SortByDateReverse').should == expected
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByAlpha" do
    expected = "<ul>" +
      "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory Testing a Real Cat SortByAlpha').should == expected
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByAlphaReverse" do
    expected = "<ul>" +
      "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory Testing a Real Cat SortByAlphaReverse').should == expected
  end
end

describe "content pages limited number of listings" do
  before(:each) do
    real_category = Category.create! :name => "Testing a Real Cat"
    @cp1 = ContentPage.create! :name => 'Page A from 9 days ago', :publish_on => 9.days.ago, :is_preview_only => false
    @cp2 = ContentPage.create! :name => 'Page B from 5 days ago', :publish_on => 5.days.ago, :is_preview_only => false
    @cp3 = ContentPage.create! :name => 'Page C from 7 days ago', :publish_on => 7.days.ago, :is_preview_only => false
    [@cp1, @cp2, @cp3].each do |cp|
      assert cp.categories << real_category
      assert cp.save
    end
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByDate Limit=2" do
    expected = "<ul>" +
      "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory Testing a Real Cat SortByDate Limit=2').should == expected
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByAlpha Limit=2" do
    expected = "<ul>" +
      "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>" +
      "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory Testing a Real Cat SortByAlpha Limit=2').should == expected
  end
end


describe "lists of content pages with published dates" do
  it "should not display pages that are not ready to be published yet" do
    real_category = Category.create! :name => "Testing a Real Cat"
    cp1 = ContentPage.create! :name => 'Page A from 9 days ago', :publish_on => 9.days.ago, :is_preview_only => false
    cp2 = ContentPage.create! :name => 'Page B 5 days from now', :publish_on => 5.days.from_now, :is_preview_only => false
    [cp1, cp2].each do |cp|
      assert cp.categories << real_category
      assert cp.save
    end

    expected = "<ul>" +
      "<li><a href=\"/content_pages/#{cp1.id}\">Page A from 9 days ago</a></li>" +
      "</ul>"
    ContentPage.function('ListPagesInCategory Testing a Real Cat').should == expected
  end
end


# == Schema Information
#
# Table name: content_pages
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  body               :text
#  special            :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  is_preview_only    :boolean
#  started_editing_at :datetime
#  editing_user_id    :integer
#  publish_on         :date
#  layout             :string(255)
#

