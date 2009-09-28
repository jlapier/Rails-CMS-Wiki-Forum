require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_comments/new.html.erb" do
  include WikiCommentsHelper

  before(:each) do
    assigns[:wiki_comment] = stub_model(WikiComment,
      :new_record? => true
    )
  end

  it "renders new wiki_comment form" do
    render

    response.should have_tag("form[action=?][method=post]", wiki_comments_path) do
    end
  end
end
