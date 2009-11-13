require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContentPage do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :body => "value for body"
    }
  end

  it "should create a new instance given valid attributes" do
    ContentPage.create!(@valid_attributes)
  end

  #   ListCategories    // lists all categories
  #   ListPagesInCategory Some Kind of Category    // list all pages in the category called "Some Kind of Category"
  #   LinkPage Page Name  // links directly to the page specified
  #   LinkCategory Some Kind of Category    // links to the category index page
  it "should generate HTML from function ListCategories" do
    @mock_category = Category.new :name => 'test'
    @mock_category.stub!(:id).and_return(1)
    Category.should_receive(:find).with(:all).and_return([@mock_category])
    
    lines = ContentPage.function('ListCategories').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/categories/1\">test</a></li>"
    lines[2].should == "</ul>"
  end

  it "should generate HTML from function ListCategories WithHome" do
    @mock_category = Category.new :name => 'test'
    @mock_category.stub!(:id).and_return(1)
    Category.should_receive(:find).with(:all).and_return([@mock_category])

    lines = ContentPage.function('ListCategories WithHome').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/\">Home</a></li>"
    lines[2].should == "<li><a href=\"/categories/1\">test</a></li>"
    lines[3].should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category" do
    @mock_category = Category.new :name => 'A Test Category'
    @mock_content_page = ContentPage.new :name => 'Page ABC'
    @mock_content_page.stub!(:id).and_return(123)
    @mock_category.stub!(:content_pages).and_return([@mock_content_page])
    Category.should_receive(:find_by_name).with('A Test Category').and_return(@mock_category)

    lines = ContentPage.function('ListPagesInCategory A Test Category').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/content_pages/123\">Page ABC</a></li>"
    lines[2].should == "</ul>"
  end

  it "should generate HTML from function ListPagesInCategory A Test Category WithHome" do
    @mock_category = Category.new :name => 'A Test Category'
    @mock_content_page = ContentPage.new :name => 'Page ABC'
    @mock_content_page.stub!(:id).and_return(123)
    @mock_category.stub!(:content_pages).and_return([@mock_content_page])
    Category.should_receive(:find_by_name).with('A Test Category').and_return(@mock_category)

    lines = ContentPage.function('ListPagesInCategory A Test Category WithHome').split("\n")
    lines[0].should == "<ul>"
    lines[1].should == "<li><a href=\"/\">Home</a></li>"
    lines[2].should == "<li><a href=\"/content_pages/123\">Page ABC</a></li>"
    lines[3].should == "</ul>"
  end
end
