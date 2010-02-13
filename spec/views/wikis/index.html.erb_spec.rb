require 'spec_helper'

describe "/wikis/index.html.erb" do
  include WikisHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:wikis] = [
      stub_model(Wiki, :name => "Some wiki"),
      stub_model(Wiki, :name => "Some other wiki")
    ]
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of wikis" do
    render
    response.should have_text /Some wiki/
    response.should have_text /Some other wiki/
  end
end
