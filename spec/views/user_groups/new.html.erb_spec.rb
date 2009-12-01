require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_groups/new.html.erb" do
  include UserGroupsHelper

  before(:each) do
    assigns[:user_group] = stub_model(UserGroup,
      :new_record? => true
    )
  end

  it "renders new user_group form" do
    render

    response.should have_tag("form[action=?][method=post]", user_groups_path) do
    end
  end
end
