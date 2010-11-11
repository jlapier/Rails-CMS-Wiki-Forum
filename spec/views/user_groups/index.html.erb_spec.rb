require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_groups/index.html.erb" do
  include UserGroupsHelper
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end
  before(:each) do
    assign(:user_groups, [
      stub_model(UserGroup),
      stub_model(UserGroup)
    ])
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of user_groups" do
    render
  end
end
