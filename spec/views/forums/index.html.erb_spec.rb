require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/index.html.erb" do
  include ForumsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:name => 'User',:is_admin? => true}))
  end

  before(:each) do
    @message1 = stub_model(MessagePost, {
      :subject => 'Subject 1',
      :body => 'I am Message 1',
      :user => mock_user,
      :created_at => Date.yesterday
    })
    @message2 = stub_model(MessagePost, {
      :subject => '2 Subject',
      :body => '2 Message am I',
      :user => mock_user,
      :created_at => 2.days.ago
    })
    @forums = [
      stub_model(Forum,
        :title => "value for title 1",
        :description => "value for description 1",
        :position => 1,
        :moderator_only => false,
        :most_recent_post => @message1
      ),
      stub_model(Forum,
        :title => "value for title 2",
        :description => "value for description 2",
        :position => 1,
        :moderator_only => false,
        :most_recent_post => @message2
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
  it "renders the most recent message subject from each forum" do
    render
    rendered.should =~ (/Subject 1/)
    rendered.should =~ (/2 Subject/)
  end
end
