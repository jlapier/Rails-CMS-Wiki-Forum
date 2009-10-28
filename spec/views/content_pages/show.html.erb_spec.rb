require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/show.html.erb" do
  include ContentPagesHelper
  before(:each) do
    assigns[:content_page] = @content_page = stub_model(ContentPage,
      :name => "value for name",
      :body => "value for body",
      :category_id => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ body/)
    response.should have_text(/1/)
  end
end
