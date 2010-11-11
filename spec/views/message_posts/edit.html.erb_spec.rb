require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/message_posts/edit.html.erb" do
  include MessagePostsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    @forum = stub_model(Forum, :title => "The Forum")
    @message_post = stub_model(MessagePost,
      :subject => "value for subject",
      :body => "value for body",
      :forum => @forum,
      :parent_id => 1,
      :user => mock_user,
      :to_user_id => 1,
      :thread_id => 1
    )
    assign(:forum, @forum)
    assign(:message_post, @message_post)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders the edit message_post form" do
    render

    rendered.should have_selector("form[action='#{forum_message_post_path(@forum, @message_post)}'][method='post']") do |scope|
      scope.should have_selector('input#message_post_subject[name="message_post[subject]"]')
      scope.should have_selector('textarea#message_post_body[name="message_post[body]"]')
      scope.should have_selector('input#message_post_forum_id[name="message_post[forum_id]"]')
      scope.should have_selector('input#message_post_thread_id[name="message_post[thread_id]"]')
    end

    rendered.should =~  /The Forum/
  end
  
end
