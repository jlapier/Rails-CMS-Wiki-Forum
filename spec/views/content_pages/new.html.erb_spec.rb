require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/new.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    Category.stub!(:find).and_return([stub_model(Category, :name => 'cat')])
    assigns[:content_page] = stub_model(ContentPage,
      :new_record? => true,
      :name => "value for name",
      :body => "value for body",
      :categories => []
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders new content_page form" do
    render

    response.should have_tag("form[action=?][method=post]", content_pages_path) do
      with_tag("input#content_page_name[name=?]", "content_page[name]")
      without_tag("textarea#content_page_body[name=?]", "content_page[body]")
      with_tag("input[type=checkbox][name=?]", 'content_page[category_ids][]')
    end
  end
end
