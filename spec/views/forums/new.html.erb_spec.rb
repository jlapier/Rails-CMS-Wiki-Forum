require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/new.html.erb" do
  include ForumsHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:forum] = stub_model(Forum,
      :new_record? => true,
      :title => "value for title",
      :description => "value for description",
      :position => 1,
      :moderator_only => false,
      :newest_message_post_id => 1
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders new forum form" do
    render

    response.should have_tag("form[action=?][method=post]", forums_path) do
      with_tag("input#forum_title[name=?]", "forum[title]")
      with_tag("textarea#forum_description[name=?]", "forum[description]")
    end
  end
end
