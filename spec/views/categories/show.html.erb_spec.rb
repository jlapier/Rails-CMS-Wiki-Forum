require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/categories/show.html.erb" do
  include CategoriesHelper
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :logged_in? => true,
        :has_read_access_to? => true, :has_write_access_to? => true,
        :name => 'John', :email => 'john@text.com', :first_name => 'John',
        :last_name => 'Doe', :fullname => 'John Doe'}))
  end

  before(:each) do
    controller.stub(:current_user){ mock_user }
    @category = mock_model(Category,
      :name => "Name",
      :content_pages => [stub_model(ContentPage, :name => 'nothing', :body => 'more nothing')],
      :blog_posts => [stub_model(Blog::Post, :title => 'something', :body => 'more something', :author => mock_user)])
    assign(:category, @category)
    view.stub(:current_user).and_return(mock_user)
    view.stub(:has_authorization?){ true }
  end
  
  it "renders category info" do
    render
    rendered.should contain('Name')
  end

  it "renders a list of pages" do
    render
    rendered.should contain('nothing')
  end
  
  it "renders a list of blog posts" do
    render
    rendered.should contain('something')
  end
  
end
