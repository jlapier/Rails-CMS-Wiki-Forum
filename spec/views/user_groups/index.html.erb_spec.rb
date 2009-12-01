require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_groups/index.html.erb" do
  include UserGroupsHelper

  before(:each) do
    assigns[:user_groups] = [
      stub_model(UserGroup),
      stub_model(UserGroup)
    ]
  end

  it "renders a list of user_groups" do
    render
  end
end
