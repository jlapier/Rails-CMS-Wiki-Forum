require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/index.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    @p1 = stub_model(ContentPage,
      :name => "value for name one",
      :body => "value for body one"
    )
    @p1.stub(:categories).and_return([])
    @p2 = stub_model(ContentPage,
      :name => "value for name two",
      :body => "value for body two"
    )
    @p2.stub(:categories).and_return([])
    assign(:content_pages, [@p1,@p2])
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders a list of content_pages" do
    render
    rendered.should have_selector("tr>td") do |scope|
      scope.should contain "value for name one"
      scope.should contain "value for body one"
      scope.should contain "value for name two"
      scope.should contain "value for body two"
    end
  end
end
