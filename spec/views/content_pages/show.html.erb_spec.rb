require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/show.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => false}))
  end

  before(:each) do
    @content_page = stub_model(ContentPage,
      :name => "value for name",
      :body_for_display => "value for body"
    )
    @content_page.stub(:categories).and_return([stub_model(Category, :name => 'somecategory')])
    assign(:content_page, @content_page)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders a page" do
    render
    rendered.should =~ (/value\ for\ name/)
    rendered.should =~ (/value\ for\ body/)
    rendered.should =~ (/somecategory/)
  end
end
