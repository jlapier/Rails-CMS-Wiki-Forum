require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_groups/new.html.erb" do
  include UserGroupsHelper

  before(:each) do
    assign(:user_group, stub_model(UserGroup).as_new_record)
  end

  it "renders new user_group form" do
    render

    rendered.should have_selector("form[action='#{user_groups_path}'][method='post']") do
    end
  end
end
