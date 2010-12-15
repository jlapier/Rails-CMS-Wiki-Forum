require 'spec_helper'

describe "/wikis/show.html.erb" do
  include WikisHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true, :email => 'a@b', :name => 'dude',
          :full_name => 'dude man'}))
  end

  before(:each) do
    @wiki_pages = [
        stub_model(WikiPage, :title => 'wp 1', :url_title => 'wp_1', :updated_at => 3.days.ago),
        stub_model(WikiPage, :title => 'wp 2', :url_title => 'wp_2', :updated_at => 4.days.ago)
      ].paginate :page => 1, :per_page => 2
    @wiki = stub_model(Wiki, :name => "Some page")
    @wiki.stub(:wiki_pages).and_return(@wiki_pages)
    assign(:wiki_pages, @wiki_pages)
    assign(:wiki, @wiki)
    assign(:users_with_access, [mock_user])
    view.controller.stub(:current_user).and_return(mock_user)
    view.stub(:current_user).and_return(mock_user)
  end

  it "renders list of pages" do
    render

    rendered.should =~  /wp 1/
    rendered.should =~  /wp 2/
  end
end
