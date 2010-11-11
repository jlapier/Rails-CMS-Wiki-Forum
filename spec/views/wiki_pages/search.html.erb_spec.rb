require 'spec_helper'

describe "/wiki_pages/search.html.erb" do
  include WikiPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    @wiki_tags = [ stub_model(WikiTag, :name => 'taggo', :wiki_pages_count => 5) ]
    assign(:name_part, "Test thing")
    assign(:wiki, stub_model(Wiki, :name => "Some wiki"))
    assign(:wiki_tags, @wiki_tags)
    assign(:wiki_pages, [
      stub_model(WikiPage, :title => "Some page", :url_title => "Some_page", :body => 'Some Test thing'),
      stub_model(WikiPage, :title => "Some other page", :url_title => "Some_other_page", :body => 'Some other thing Test')
    ])
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of pages" do
    render
    rendered.should =~  /Test thing/
    rendered.should =~  /Some page/
    rendered.should =~  /Some other page/
    rendered.should =~  /taggo/
  end
end
