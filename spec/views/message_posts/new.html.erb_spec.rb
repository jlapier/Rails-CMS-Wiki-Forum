require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/message_posts/new.html.erb" do
  include MessagePostsHelper

  before(:each) do
    assigns[:message_post] = stub_model(MessagePost,
      :new_record? => true,
      :subject => "value for subject",
      :body => "value for body",
      :forum_id => 1,
      :parent_id => 1,
      :user_id => 1,
      :to_user_id => 1,
      :thread_id => 1
    )
  end

  it "renders new message_post form" do
    render

    response.should have_tag("form[action=?][method=post]", message_posts_path) do
      with_tag("input#message_post_subject[name=?]", "message_post[subject]")
      with_tag("textarea#message_post_body[name=?]", "message_post[body]")
      with_tag("input#message_post_forum_id[name=?]", "message_post[forum_id]")
      with_tag("input#message_post_parent_id[name=?]", "message_post[parent_id]")
      with_tag("input#message_post_user_id[name=?]", "message_post[user_id]")
      with_tag("input#message_post_to_user_id[name=?]", "message_post[to_user_id]")
      with_tag("input#message_post_thread_id[name=?]", "message_post[thread_id]")
    end
  end
end
