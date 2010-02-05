require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/categories/index.html.erb" do
  include CategoriesHelper

  before(:each) do
    assigns[:category] = stub_model(Category,
      :new_record? => true
    )
    assigns[:categories] = [
      stub_model(Category, :content_pages => [stub_model(ContentPage, :title => 'nothing', :body_for_display => 'more nothing')]),
      stub_model(Category, :content_pages => [])
    ]
  end

  it "renders a list of categories" do
    render
  end
end
