require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/message_posts/show.html.erb" do
  include MessagePostsHelper
  before(:each) do
    assigns[:message_post] = @message_post = stub_model(MessagePost,
      :subject => "value for subject",
      :body => "value for body",
      :forum_id => 1,
      :parent_id => 1,
      :user_id => 1,
      :to_user_id => 1,
      :thread_id => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ subject/)
    response.should have_text(/value\ for\ body/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end
