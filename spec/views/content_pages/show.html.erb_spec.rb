require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/show.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => false}))
  end

  before(:each) do
    assigns[:content_page] = @content_page = stub_model(ContentPage,
      :name => "value for name",
      :body_for_display => "value for body",
      :categories => [stub_model(Category, :name => 'somecategory')]
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders a page" do
    render
    response.should =~ (/value\ for\ name/)
    response.should =~ (/value\ for\ body/)
    response.should =~ (/somecategory/)
  end
end
