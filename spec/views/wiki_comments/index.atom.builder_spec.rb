require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_comments/index.atom.builder" do
  include WikiCommentsHelper

  before(:each) do
    user = stub_model(User, :name => "Joe")
    wiki_page = stub_model(WikiPage, :title => "A Page", :url_title => "A_Page")
    assign(:wiki, stub_model(Wiki, :name => 'Some wiki'))
    assign(:comments, [
      stub_model(WikiComment, :user => user, :created_at => 3.days.ago, :wiki_page => wiki_page, :body => "body A"),
      stub_model(WikiComment, :user => user, :created_at => 3.days.ago, :body => "body B").as_new_record,
      stub_model(WikiComment, :user => nil, :created_at => 3.days.ago, :wiki_page => wiki_page, :body => "body C")
    ])
  end

  it "renders a list of wiki_comments" do
    render
  end
end
