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
    lines = ContentPage.function('ListCategories').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/categories/1\">A Test Category</a></li>"
    lines[2].should == "</ul>"
  end

  it "should generate HTML from function ListCategories WithHome" do
    Category.should_receive(:find).with(:all, {:order=>"name ASC", :limit => nil}).and_return([@mock_category])
    lines = ContentPage.function('ListCategories WithHome').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/\">Home</a></li>"
    lines[2].should == "<li><a href=\"/categories/1\">A Test Category</a></li>"
    lines[3].should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category" do
    mock_association_proxy = [@mock_content_page]
    mock_association_proxy.stub!(:find).and_return(mock_association_proxy)
    @mock_category.stub!(:content_pages).and_return(mock_association_proxy)
    Category.should_receive(:find_by_name).with('A Test Category').and_return(@mock_category)

    lines = ContentPage.function('ListPagesInCategory A Test Category').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/content_pages/123\">Page ABC</a></li>"
    lines[2].should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category WithHome" do
    mock_association_proxy = [@mock_content_page]
    mock_association_proxy.stub!(:find).and_return(mock_association_proxy)
    @mock_category.stub!(:content_pages).and_return(mock_association_proxy)
    Category.should_receive(:find_by_name).with('A Test Category').and_return(@mock_category)

    lines = ContentPage.function('ListPagesInCategory A Test Category WithHome').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/\">Home</a></li>"
    lines[2].should == "<li><a href=\"/content_pages/123\">Page ABC</a></li>"
    lines[3].should == "</ul>"
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
    lines = ContentPage.function('ListPagesInCategory Testing a Real Cat SortByDate').split("\n")
    lines.shift.should == "<ul>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>"
    lines.shift.should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByDateReverse" do
    lines = ContentPage.function('ListPagesInCategory Testing a Real Cat SortByDateReverse').split("\n")
    lines.shift.should == "<ul>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>"
    lines.shift.should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByAlpha" do
    lines = ContentPage.function('ListPagesInCategory Testing a Real Cat SortByAlpha').split("\n")
    lines.shift.should == "<ul>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>"
    lines.shift.should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByAlphaReverse" do
    lines = ContentPage.function('ListPagesInCategory Testing a Real Cat SortByAlphaReverse').split("\n")
    lines.shift.should == "<ul>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>"
    lines.shift.should == "</ul>"
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
    lines = ContentPage.function('ListPagesInCategory Testing a Real Cat SortByDate Limit=2').split("\n")
    lines.shift.should == "<ul>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp3.id}\">Page C from 7 days ago</a></li>"
    lines.shift.should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category SortByAlpha Limit=2" do
    lines = ContentPage.function('ListPagesInCategory Testing a Real Cat SortByAlpha Limit=2').split("\n")
    lines.shift.should == "<ul>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp1.id}\">Page A from 9 days ago</a></li>"
    lines.shift.should == "<li><a href=\"/content_pages/#{@cp2.id}\">Page B from 5 days ago</a></li>"
    lines.shift.should == "</ul>"
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

    lines = ContentPage.function('ListPagesInCategory Testing a Real Cat').split("\n")
    lines.shift.should == "<ul>"
    lines.shift.should == "<li><a href=\"/content_pages/#{cp1.id}\">Page A from 9 days ago</a></li>"
    lines.shift.should == "</ul>"
  end
end