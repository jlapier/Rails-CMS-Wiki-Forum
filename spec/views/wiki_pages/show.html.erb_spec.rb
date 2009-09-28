require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/show.html.erb" do
  include WikiPagesHelper
  before(:each) do
    assigns[:wiki_page] = @wiki_page = stub_model(WikiPage)
  end

  it "renders attributes in <p>" do
    render
  end
end
