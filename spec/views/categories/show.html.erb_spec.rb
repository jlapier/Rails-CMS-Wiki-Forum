require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/categories/show.html.erb" do
  include CategoriesHelper
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end

  before(:each) do
    @category = mock_model(Category,
      :name => "Name",
      :content_pages => [stub_model(ContentPage, :title => 'nothing', :body_for_display => 'more nothing')])
    assign(:category, @category)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders category and list of pages" do
    render
  end
end
