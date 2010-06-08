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
    assigns[:wiki_pages] = @wiki_pages
    assigns[:wiki] = @wiki = stub_model(Wiki, :name => "Some page",
      :wiki_pages => @wiki_pages)
    assigns[:users_with_access] = [mock_user]
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders list of pages" do
    render

    response.should have_text /wp 1/
    response.should have_text /wp 2/
  end
end
