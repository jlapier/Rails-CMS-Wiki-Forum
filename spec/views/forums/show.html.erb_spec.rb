require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/show.html.erb" do
  include ForumsHelper
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true, :email => 'a@b', :name => 'dude', :full_name => 'Dude McDuder', :single_access_token => 'single access token'}))
  end
  
  before(:each) do
    @message_posts = [
        stub_model(MessagePost, :subject => 'messsub1', :body => 'messbody', :user => mock_user, :created_at => 5.days.ago),
        stub_model(MessagePost, :subject => 'messsub2', :body => 'messbody', :user => mock_user, :created_at => 15.days.ago)
      ].paginate :page => 1, :per_page => 2
    assign(:message_posts, @message_posts)
    @forum = stub_model(Forum,
      :title => "value for title",
      :description => "value for description",
      :message_posts => @message_posts
    )
    assign(:forum, @forum)
    assign(:users_with_access, [mock_user])
    assign(:new_message_post, MessagePost.new)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders attributes for forum" do
    render
    rendered.should =~ (/value\ for\ title/)
    rendered.should =~ (/value\ for\ description/)
    rendered.should =~ (/messsub1/)
    rendered.should =~ (/messsub2/)
    rendered.should =~ (/Dude McDuder/)
    rendered.should =~ (/single\+access\+token/)
  end
end
