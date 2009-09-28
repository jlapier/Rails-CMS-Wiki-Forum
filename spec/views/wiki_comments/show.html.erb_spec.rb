require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_comments/show.html.erb" do
  include WikiCommentsHelper
  before(:each) do
    assigns[:wiki_comment] = @wiki_comment = stub_model(WikiComment)
  end

  it "renders attributes in <p>" do
    render
  end
end
