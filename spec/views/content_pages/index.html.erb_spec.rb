require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/index.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:content_pages] = [
      stub_model(ContentPage,
        :name => "value for name",
        :body => "value for body",
        :categories => []
      ),
      stub_model(ContentPage,
        :name => "value for name",
        :body => "value for body",
        :categories => []
      )
    ]
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of content_pages" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for body".to_s, 2)
  end
end
