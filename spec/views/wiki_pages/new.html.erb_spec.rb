require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/new.html.erb" do
  include WikiPagesHelper

  before(:each) do
    assigns[:wiki_page] = stub_model(WikiPage,
      :new_record? => true
    )
  end

  it "renders new wiki_page form" do
    render

    response.should have_tag("form[action=?][method=post]", wiki_pages_path) do
    end
  end
end
