require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/categories/index.html.erb" do
  include CategoriesHelper

  before(:each) do
    m_cat1 = mock_model(Category, :name => "Name", :content_pages => [mock_model(ContentPage, :title => 'nothing', :body_for_display => 'more nothing')], :parent_id => nil)
    m_cat2 = mock_model(Category, :name => "Name", :content_pages => [], :parent_id => nil)
    assign(:category, stub_model(Category).as_new_record)
    assign(:categories, [ m_cat1, m_cat2 ])
    assign(:root_categories, [ m_cat1, m_cat2 ])
  end

  it "renders a list of categories" do
    render
  end
end
