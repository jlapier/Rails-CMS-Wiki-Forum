require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/categories/index.html.erb" do
  include CategoriesHelper

  before(:each) do
    assign(:category, stub_model(Category).as_new_record)
    assign(:categories, [
      mock_model(Category, :name => "Name", :content_pages => [mock_model(ContentPage, :title => 'nothing', :body_for_display => 'more nothing')]),
      mock_model(Category, :name => "Name", :content_pages => [])
    ])
  end

  it "renders a list of categories" do
    render
  end
end
