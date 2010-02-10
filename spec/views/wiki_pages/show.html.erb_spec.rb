require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/show.html.erb" do
  include WikiPagesHelper
  before(:each) do
    assigns[:wiki] = @wiki = stub_model(Wiki, :name => "some wiki")
    assigns[:wiki_page] = @wiki_page = stub_model(WikiPage, :title => "A Page", :body_for_display => "whatever",
      :updated_at => 3.days.ago, :wiki_tags => [stub_model(WikiTag, :name => 'thing')])
  end

  it "renders attributes in <p>" do
    render
  end
end
