require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forums/index.html.erb" do
  include ForumsHelper

  before(:each) do
    assigns[:forums] = [
      stub_model(Forum,
        :title => "value for title",
        :description => "value for description",
        :position => 1,
        :moderator_only => false,
        :newest_message_post_id => 1
      ),
      stub_model(Forum,
        :title => "value for title",
        :description => "value for description",
        :position => 1,
        :moderator_only => false,
        :newest_message_post_id => 1
      )
    ]
  end

  it "renders a list of forums" do
    render
    response.should have_tag("tr>td", "value for title".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
