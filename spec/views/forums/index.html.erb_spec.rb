require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/index.html.erb" do
  include ForumsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    @forums = [
      stub_model(Forum,
        :title => "value for title 1",
        :description => "value for description 1",
        :position => 1,
        :moderator_only => false,
        :newest_message_post_id => 1
      ),
      stub_model(Forum,
        :title => "value for title 2",
        :description => "value for description 2",
        :position => 1,
        :moderator_only => false,
        :newest_message_post_id => 1
      )
    ]
    assign(:forums, @forums)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of forums" do
    render
    rendered.should =~ (/value for title 1/)
    rendered.should =~ (/value for description 1/)
    rendered.should =~ (/value for title 2/)
    rendered.should =~ (/value for description 2/)
  end
end
