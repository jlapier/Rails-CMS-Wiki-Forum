require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_comments/edit.html.erb" do
  include WikiCommentsHelper

  before(:each) do
    assigns[:wiki_comment] = @wiki_comment = stub_model(WikiComment,
      :new_record? => false
    )
  end

  it "renders the edit wiki_comment form" do
    render

    response.should have_tag("form[action=#{wiki_comment_path(@wiki_comment)}][method=post]") do
    end
  end
end
