require 'spec_helper'

describe "/wikis/index.html.erb" do
  include WikisHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:wikis] = [
      stub_model(Wiki, :name => "Some page", :url_name => "Some_page"),
      stub_model(Wiki, :name => "Some other page", :url_name => "Some_other_page")
    ]
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of wikis" do
    render
    response.should have_text /Some page/
    response.should have_text /Some other page/
  end
end
