require 'spec_helper'

describe "/wikis/new.html.erb" do
  include WikisHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assign(:wiki, stub_model(Wiki,
      :name => "Some page",
      :url_name => "Some_page"
    ).as_new_record)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders new wiki form" do
    render

    rendered.should have_selector("form[action='#{wikis_path}'][method='post']") do |scope|
      scope.should have_selector 'input#wiki_name[name="wiki[name]"]'
    end
  end
end
