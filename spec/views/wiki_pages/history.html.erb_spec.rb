require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/history.html.erb" do
  include WikiPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => false, :name => "Bob"}))
  end

  before(:each) do
    @wp_ver1 = WikiPage::Version.new
    @wp_ver1.stubs :id => 1, :title => "A Pages", :body_for_display => "what", :updated_at => 6.days.ago, :version => 1
    @wp_ver2 = WikiPage::Version.new
    @wp_ver2.stubs :id => 2, :title => "A Pages", :body_for_display => "whatev", :updated_at => 5.days.ago, :version => 2
    assigns[:wiki] = @wiki = stub_model(Wiki, :name => "some wiki")
    assigns[:wiki_page_versions] = @wiki_page_versions = [ @wp_ver1, @wp_ver2 ]
    assigns[:wiki_page] = @wiki_page = stub_model(WikiPage, :title => "A Page", :body_for_display => "whatever",
      :updated_at => 3.days.ago, :wiki_tags => [stub_model(WikiTag, :name => 'thing')],
      :versions => @wiki_page_versions)
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders attributes in <p>" do
    render
  end
end
