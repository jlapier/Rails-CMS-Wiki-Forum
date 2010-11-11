require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/edit.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    @content_page = stub_model(ContentPage,
      :name => "value for name",
      :body => "value for body"
    )
    @content_page.stub(:categories).and_return([])
    Category.stub!(:find).and_return([stub_model(Category, :name => 'cat')])
    ContentPage.stub(:find).and_return(@content_page)
    assign(:assets, ['image.png', 'file.odt'])
    assign(:content_page, @content_page)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders the edit content_page form" do
    render
    rendered.should have_selector("form[action='#{content_page_path(@content_page)}'][method='post']") do
      have_selector('input#content_page_name[name="content_page[name]"]')
      have_selector('textarea#content_page_body[name="content_page[body]"]')
      have_selector("input[type=checkbox][name='content_page[category_ids][]']")
    end
  end
end
