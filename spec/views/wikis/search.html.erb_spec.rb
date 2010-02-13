require 'spec_helper'

describe "/wikis/search.html.erb" do
  include WikisHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:wiki] = stub_model(Wiki, :name => "Some wiki")
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of pages" do
    render
    response.should have_text /Some page/
    response.should have_text /Some other page/
  end
end
