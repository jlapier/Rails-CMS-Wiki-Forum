require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/index.html.erb" do
  include ContentPagesHelper

  before(:each) do
    assigns[:content_pages] = [
      stub_model(ContentPage,
        :name => "value for name",
        :body => "value for body",
        :category_id => 1
      ),
      stub_model(ContentPage,
        :name => "value for name",
        :body => "value for body",
        :category_id => 1
      )
    ]
  end

  it "renders a list of content_pages" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for body".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
