require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/new.html.erb" do
  include ContentPagesHelper

  before(:each) do
    assigns[:content_page] = stub_model(ContentPage,
      :new_record? => true,
      :name => "value for name",
      :body => "value for body",
      :category_id => 1
    )
  end

  it "renders new content_page form" do
    render

    response.should have_tag("form[action=?][method=post]", content_pages_path) do
      with_tag("input#content_page_name[name=?]", "content_page[name]")
      with_tag("textarea#content_page_body[name=?]", "content_page[body]")
      with_tag("input#content_page_category_id[name=?]", "content_page[category_id]")
    end
  end
end
