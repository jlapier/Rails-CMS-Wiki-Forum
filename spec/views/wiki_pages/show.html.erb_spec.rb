require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki_pages/show.html.erb" do
  include WikiPagesHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({
      :is_admin? => false,
      :has_read_access_to? => true,
      :has_write_access_to? => true,
      :name => "Bob"
    }))
  end

  before(:each) do
    @wiki = stub_model(Wiki, :name => "some wiki")
    @user_1 = stub_model(User, :name => "joe")
    @wiki_comment_1 = stub_model(WikiComment, :body => 'commenting on ya', :created_at => 4.days.ago)
    @wiki_comment_1.stub(:user).and_return(@user_1)
    @wiki_comment_2 = stub_model(WikiComment, :body => 'my own comment', :created_at => 3.days.ago)
    @wiki_comment_2.stub(:user).and_return(mock_user)
    @wiki_comments = [@wiki_comment_1,@wiki_comment_2]
    @wiki_tags = [stub_model(WikiTag, :name => 'thing')]
    @wiki_page = stub_model(WikiPage, {
      :title => "A Page",
      :body_for_display => "whatever",
      :updated_at => 3.days.ago,
      :wiki => @wiki
    })
    @wiki_page.stub(:wiki_comments).and_return(@wiki_comments)
    @wiki_page.stub(:wiki_tags).and_return(@wiki_tags)
    assign(:wiki, @wiki)
    assign(:wiki_page, @wiki_page)
    view.controller.stub(:current_user).and_return(mock_user)
    view.stub(:current_user).and_return(mock_user)
  end

  it "renders attributes in <p>" do
    render
  end
end
