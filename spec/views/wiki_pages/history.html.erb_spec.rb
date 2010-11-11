require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/history.html.erb" do
  include WikiPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => false, :name => "Bob"}))
  end

  before(:each) do
    @wp_ver1 = WikiPage::Version.new :id => 1, :title => "A Pages", :updated_at => 6.days.ago, :version => 1, :url_title => 'A_Pages'
    @wp_ver1.stub(:body_for_display).and_return "what"
    @wp_ver2 = WikiPage::Version.new :id => 2, :title => "A Pages", :updated_at => 5.days.ago, :version => 2, :url_title => 'A_Pages'
    @wp_ver2.stub(:body_for_display).and_return "whatev"
    @wiki = stub_model(Wiki, :name => "some wiki")
    @wiki_page_versions = [ @wp_ver1, @wp_ver2 ]
    @wiki_page = stub_model(WikiPage, :title => "A Page", :body_for_display => "whatever",
      :url_title => 'A_Page',
      :updated_at => 3.days.ago,
      :versions => @wiki_page_versions)
    @wiki_page.stub(:wiki_tags).and_return([stub_model(WikiTag, :name => 'thing')])
    assign(:wiki, @wiki)
    assign(:wiki_page_versions, @wiki_page_versions)
    assign(:wiki_page, @wiki_page)
    view.stub!(:current_user).and_return(mock_user)
  end

  it "renders attributes in <p>" do
    render
  end
end
