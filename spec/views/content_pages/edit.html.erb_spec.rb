require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/edit.html.erb" do
  include ContentPagesHelper

  before(:each) do
    assigns[:content_page] = @content_page = stub_model(ContentPage,
      :new_record? => false,
      :name => "value for name",
      :body => "value for body",
      :category_id => 1
    )
  end

  it "renders the edit content_page form" do
    render

    response.should have_tag("form[action=#{content_page_path(@content_page)}][method=post]") do
      with_tag('input#content_page_name[name=?]', "content_page[name]")
      with_tag('textarea#content_page_body[name=?]', "content_page[body]")
      with_tag('input#content_page_category_id[name=?]', "content_page[category_id]")
    end
  end
end
