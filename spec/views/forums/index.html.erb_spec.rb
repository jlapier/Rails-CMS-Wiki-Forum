require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/index.html.erb" do
  include ForumsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:forums] = [
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
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of forums" do
    render
    response.should =~ (/value for title 1/)
    response.should =~ (/value for description 1/)
    response.should =~ (/value for title 2/)
    response.should =~ (/value for description 2/)
  end
end
