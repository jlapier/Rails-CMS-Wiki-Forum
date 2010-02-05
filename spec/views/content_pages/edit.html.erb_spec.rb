require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/content_pages/edit.html.erb" do
  include ContentPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    Category.stub!(:find).and_return([stub_model(Category, :name => 'cat')])
    assigns[:assets] = ['image.png', 'file.odt']
    assigns[:content_page] = @content_page = stub_model(ContentPage,
      :new_record? => false,
      :name => "value for name",
      :body => "value for body",
      :categories => []
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders the edit content_page form" do
    render

    response.should have_tag("form[action=#{content_page_path(@content_page)}][method=post]") do
      with_tag('input#content_page_name[name=?]', "content_page[name]")
      with_tag('textarea#content_page_body[name=?]', "content_page[body]")
      with_tag("input[type=checkbox][name=?]", 'content_page[category_ids][]')
    end
  end
end
