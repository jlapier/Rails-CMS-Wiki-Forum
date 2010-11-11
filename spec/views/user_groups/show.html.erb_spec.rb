require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_groups/show.html.erb" do
  include UserGroupsHelper
  before(:each) do
    @user_group = stub_model(UserGroup)
    @user_group.stub(:users).and_return([stub_model(User, :login => 'joe', :fullname => 'Joe Blow', :email => 'joeblow@a.c')])
    assign(:user_group, @user_group)
  end

  it "renders attributes in <p>" do
    render
  end
end
