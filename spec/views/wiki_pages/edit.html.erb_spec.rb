require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/edit.html.erb" do
  include WikiPagesHelper

  before(:each) do
    assigns[:rel_dir] = '/'
    assigns[:assets] = ['filea', 'fileb']
    assigns[:wiki] = @wiki = stub_model(Wiki, :name => "some wiki")
    assigns[:wiki_tags] = [stub_model(WikiTag, :name => "tag a")]
    assigns[:wiki_page] = @wiki_page = stub_model(WikiPage,
      :new_record? => false, :wiki_tags => [stub_model(WikiTag, :name => "tag 1")]
    )
  end

  it "renders the edit wiki_page form" do
    render

    response.should have_tag("form[action=#{wiki_wiki_page_path(@wiki, @wiki_page)}][method=post]") do
    end
  end
end
