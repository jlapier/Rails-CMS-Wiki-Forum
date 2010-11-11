require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/new.html.erb" do
  include WikiPagesHelper
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true,
        :has_read_access_to? => true, :has_write_access_to? => true}))
  end
  before(:each) do
    @wiki = stub_model(Wiki, :name => "some wiki")
    @wiki_page = stub_model(WikiPage).as_new_record
    @wiki_tags = [stub_model(WikiTag, :name => "tag a")]
    @wiki_page.stub(:wikis).and_return([])
    @wiki_page.stub(:wiki_tags).and_return(@wiki_tags)
    assign(:wiki, @wiki)
    assign(:wiki_tags, @wiki_tags)
    assign(:wiki_page, @wiki_page)
    
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders new wiki_page form" do
    render

    rendered.should have_selector("form[action='#{wiki_wiki_pages_path(@wiki)}'][method='post']") do
    end
  end
end
