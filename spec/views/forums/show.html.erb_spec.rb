require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/show.html.erb" do
  include ForumsHelper
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true, :email => 'a@b', :name => 'dude', :full_name => 'Dude McDuder'}))
  end
  
  before(:each) do
    @message_posts = [
        stub_model(MessagePost, :subject => 'messsub1', :body => 'messbody', :user => mock_user, :created_at => 5.days.ago),
        stub_model(MessagePost, :subject => 'messsub2', :body => 'messbody', :user => mock_user, :created_at => 15.days.ago)
      ].paginate :page => 1, :per_page => 2
    assigns[:message_posts] = @message_posts
    assigns[:forum] = @forum = stub_model(Forum,
      :title => "value for title",
      :description => "value for description",
      :message_posts => @message_posts
    )
    assigns[:new_message_post] = MessagePost.new
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders attributes for forum" do
    render
    response.should have_text(/value\ for\ title/)
    response.should have_text(/value\ for\ description/)
    response.should have_text(/messsub1/)
    response.should have_text(/messsub2/)
    response.should have_text(/Dude McDuder/)
  end
end
