require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/edit.html.erb" do
  include WikiPagesHelper
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end
  before(:each) do
    assign(:rel_dir, '/')
    assign(:assets, ['filea', 'fileb'])
    @wiki = stub_model(Wiki, :name => "some wiki")
    @wiki_page = stub_model(WikiPage)
    @wiki_page.stub(:wiki_tags).and_return([stub_model(WikiTag, :name => "tag 1")])
    assign(:wiki, @wiki)
    assign(:wiki_tags, [stub_model(WikiTag, :name => "tag a")])
    assign(:wiki_page, @wiki_page)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders the edit wiki_page form" do
    render

    rendered.should have_selector("form[action='#{wiki_wiki_page_path(@wiki, @wiki_page)}'][method='post']") do
    end
  end
end
