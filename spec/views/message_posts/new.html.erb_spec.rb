require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/message_posts/new.html.erb" do
  include MessagePostsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:forum] = @forum = stub_model(Forum, :title => "The Forum")
    assigns[:message_post] = stub_model(MessagePost,
      :new_record? => true,
      :subject => "value for subject",
      :body => "value for body",
      :forum => @forum,
      :parent_id => 1,
      :user => mock_user,
      :to_user_id => 1,
      :thread_id => 1
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders new message_post form" do
    render

    response.should have_tag("form[action=?][method=post]", forum_message_posts_path(@forum)) do
      with_tag("input#message_post_subject[name=?]", "message_post[subject]")
      with_tag("textarea#message_post_body[name=?]", "message_post[body]")
      with_tag("input#message_post_forum_id[name=?]", "message_post[forum_id]")
      with_tag("input#message_post_thread_id[name=?]", "message_post[thread_id]")
    end
  end
end
