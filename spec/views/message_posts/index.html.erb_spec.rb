require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/message_posts/index.html.erb" do
  include MessagePostsHelper

  before(:each) do
    assigns[:message_posts] = [
      stub_model(MessagePost,
        :subject => "value for subject",
        :body => "value for body",
        :forum_id => 1,
        :parent_id => 1,
        :user_id => 1,
        :to_user_id => 1,
        :thread_id => 1
      ),
      stub_model(MessagePost,
        :subject => "value for subject",
        :body => "value for body",
        :forum_id => 1,
        :parent_id => 1,
        :user_id => 1,
        :to_user_id => 1,
        :thread_id => 1
      )
    ]
  end

  it "renders a list of message_posts" do
    render
    response.should have_tag("tr>td", "value for subject".to_s, 2)
    response.should have_tag("tr>td", "value for body".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
