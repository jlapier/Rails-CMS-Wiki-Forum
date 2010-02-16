require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/message_posts/show.html.erb" do
  include MessagePostsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true, :name => "dude", :full_name => 'Dude McDuder',
          :email => "a@b"}))
  end

  before(:each) do
    assigns[:forum] = @forum = stub_model(Forum, :title => "The Forum")
    @child_posts = [
        stub_model(MessagePost, :subject => 'messsub1', :body => 'messbody', 
          :user => mock_user, :created_at => 5.days.ago, :updated_at => 3.days.ago),
        stub_model(MessagePost, :subject => 'messsub2', :body => 'messbody',
          :user => mock_user, :created_at => 15.days.ago, :updated_at => 13.days.ago)
      ].paginate :page => 1, :per_page => 2
    assigns[:child_posts] = @child_posts
    assigns[:message_post] = @message_post = stub_model(MessagePost,
      :subject => "value for subject",
      :body => "value for body",
      :created_at => 5.days.ago,
      :updated_at => 3.days.ago,
      :forum => @forum,
      :user => mock_user,
      :thread_id => 1
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders attributes in some page not really used I think" do
    render
    response.should have_text(/value\ for\ subject/)
    response.should have_text(/value\ for\ body/)
  end
end
