require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/edit.html.erb" do
  include WikiPagesHelper

  before(:each) do
    assigns[:wiki_page] = @wiki_page = stub_model(WikiPage,
      :new_record? => false
    )
  end

  it "renders the edit wiki_page form" do
    render

    response.should have_tag("form[action=#{wiki_page_path(@wiki_page)}][method=post]") do
    end
  end
end
