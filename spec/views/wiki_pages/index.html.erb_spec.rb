require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/index.html.erb" do
  include WikiPagesHelper

  before(:each) do
    assigns[:wiki_pages] = [
      stub_model(WikiPage),
      stub_model(WikiPage)
    ]
  end

  it "renders a list of wiki_pages" do
    render
  end
end
