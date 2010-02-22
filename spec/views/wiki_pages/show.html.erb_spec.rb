require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/show.html.erb" do
  include WikiPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => false, :name => "Bob"}))
  end

  before(:each) do
    assigns[:wiki] = @wiki = stub_model(Wiki, :name => "some wiki")
    assigns[:wiki_page] = @wiki_page = stub_model(WikiPage, :title => "A Page", :body_for_display => "whatever",
      :updated_at => 3.days.ago, :wiki_tags => [stub_model(WikiTag, :name => 'thing')],
      :wiki_comments => [
        stub_model(WikiComment, :body => 'commenting on ya', :created_at => 4.days.ago,
          :user => stub_model(User, :name => "joe")),
        stub_model(WikiComment, :body => 'my own comment', :created_at => 3.days.ago,
          :user => mock_user)
      ])
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders attributes in <p>" do
    render
  end
end
