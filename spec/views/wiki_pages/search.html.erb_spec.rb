require 'spec_helper'

describe "/wiki_pages/search.html.erb" do
  include WikiPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:name_part] = "Test thing"
    assigns[:wiki] = stub_model(Wiki, :name => "Some wiki")
    assigns[:wiki_pages] = [
      stub_model(WikiPage, :title => "Some page", :url_title => "Some_page"),
      stub_model(WikiPage, :title => "Some other page", :url_title => "Some_other_page")
    ]
    assigns[:wiki_tags] = [ stub_model(WikiTag, :name => 'taggo', :wiki_pages_count => 5) ]
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of pages" do
    render
    response.should have_text /Test thing/
    response.should have_text /Some page/
    response.should have_text /Some other page/
    response.should have_text /taggo/
  end
end
