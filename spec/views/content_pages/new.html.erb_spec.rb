require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/new.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    Category.stub!(:find).and_return([stub_model(Category, :name => 'cat')])
    @p = stub_model(ContentPage,
      :name => "value for name",
      :body => "value for body"
    ).as_new_record
    @p.stub(:categories).and_return([])
    assign(:content_page, @p)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders new content_page form" do
    render
    rendered.should have_selector("form[action='#{content_pages_path}'][method='post']") do |scope|
      scope.should have_selector("input#content_page_name[name='content_page[name]']")
      scope.should_not have_selector("textarea#content_page_body[name='content_page[body]']")
      scope.should have_selector("input[type=checkbox][name='content_page[category_ids][]']")
    end
  end
end
