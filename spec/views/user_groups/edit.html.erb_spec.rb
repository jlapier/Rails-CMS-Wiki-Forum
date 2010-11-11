require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_groups/edit.html.erb" do
  include UserGroupsHelper

  before(:each) do
    @user_group = stub_model(UserGroup,
      :new_record? => false
    )
    assign(:user_group, @user_group)
  end

  it "renders the edit user_group form" do
    render

    rendered.should have_selector("form[action='#{user_group_path(@user_group)}'][method='post']") do
    end
  end
end
