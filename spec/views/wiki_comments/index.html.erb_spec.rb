require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_comments/index.html.erb" do
  include WikiCommentsHelper

  before(:each) do
    assigns[:wiki_comments] = [
      stub_model(WikiComment),
      stub_model(WikiComment)
    ]
  end

  it "renders a list of wiki_comments" do
    render
  end
end
