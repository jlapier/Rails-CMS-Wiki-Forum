require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/new.html.erb" do
  include WikiPagesHelper

  before(:each) do
    assigns[:wiki] = @wiki = stub_model(Wiki, :name => "some wiki")
    assigns[:wiki_tags] = [stub_model(WikiTag, :name => "tag a")]
    assigns[:wiki_page] = stub_model(WikiPage,
      :new_record? => true, :wiki_tags => []
    )
  end

  it "renders new wiki_page form" do
    render

    response.should have_tag("form[action=?][method=post]", wiki_wiki_pages_path(@wiki)) do
    end
  end
end
