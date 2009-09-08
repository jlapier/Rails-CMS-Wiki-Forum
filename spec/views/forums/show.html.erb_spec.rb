require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/show.html.erb" do
  include ForumsHelper
  before(:each) do
    assigns[:forum] = @forum = stub_model(Forum,
      :title => "value for title",
      :description => "value for description",
      :position => 1,
      :moderator_only => false,
      :newest_message_post_id => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ title/)
    response.should have_text(/value\ for\ description/)
    response.should have_text(/1/)
    response.should have_text(/false/)
    response.should have_text(/1/)
  end
end
