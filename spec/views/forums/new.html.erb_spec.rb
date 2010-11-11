require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/new.html.erb" do
  include ForumsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    @forum = stub_model(Forum,
      :title => "value for title",
      :description => "value for description",
      :position => 1,
      :moderator_only => false,
      :newest_message_post_id => 1
    ).as_new_record
    assign(:forum, @forum)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders new forum form" do
    render

    rendered.should have_selector("form[action='#{forums_path}'][method='post']") do |scope|
      scope.should have_selector("input#forum_title[name='forum[title]']")
      scope.should have_selector("textarea#forum_description[name='forum[description]']")
    end
  end
end
