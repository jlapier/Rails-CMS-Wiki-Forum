require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  def mock_wiki
    @mock_wiki ||= mock_model(Wiki, :name => 'Wiki A')
  end

  def mock_forum
    @mock_wiki ||= mock_model(Forum, :name => 'Forum A')
  end

  def mock_admin_user(stubs={})
    @mock_user ||= mock_model(User, {:is_admin? => true, :first_name => "Jason",
        :has_access_to_any_wikis? => false, :has_access_to_any_forums? => false}.merge(stubs))
  end

  it "should have a top menu" do
    helper.top_menu.should == "TODO: create the top menu"
  end

  it "should have a side menu" do
    helper.side_menu.should == "TODO: create the side menu"
  end

  it "should have a logo image" do
    helper.logo_image.should =~ (/img/)
  end

  it "should have a site title" do
    helper.site_title.should == "A Site"
  end

  it "should have a page title" do
    assign(:content_page, mock_model(ContentPage, :name => "Test Page")
    )
    helper.stub(:action_name).and_return "edit"
    helper.stub(:controller_name).and_return "content_pages"
    helper.page_title.should == "Editing Test Page"
  end

  it "should have a site logo" do
    helper.site_logo.should == "GenericLogo.png"
  end

  it "should have a site footer" do
    helper.site_footer.should == "Content on this site is the copyright of the owners of test.host and is provided as-is without warranty."
  end

  it "should have a user box with a log in link" do
    # avoid MethodMissing for link_to_events
    helper.class.send :include, EventCalendar::ApplicationHelper
    helper.stub(:current_user).and_return(nil)
    helper.user_box.should =~ (/Log In/)
    helper.user_box.should =~ (/Register/)
    helper.user_box.should =~ (/Events/)
  end

  it "should have a user box with welcome message" do
    helper.stub(:current_user).and_return(mock_admin_user)
    helper.user_box.should =~ (/Welcome, Jason!/)
    helper.user_box.should_not =~ (/Wiki/)
    helper.user_box.should_not =~ (/Forum/)
  end

  it "should have a user box with admin links" do
    helper.stub(:current_user).and_return(mock_admin_user)
    helper.user_box.should =~ (/Site Admin/)
  end

  it "should have a user box with one wiki link" do
    helper.stub(:current_user).and_return(mock_admin_user(:has_access_to_any_wikis? => true, :wikis => [mock_wiki]))
    helper.user_box.should =~ (/Wiki/)
    helper.user_box.should =~ (/href="\/wikis\/#{mock_wiki.id}"/)
    helper.user_box.should_not =~ (/Forum/)
  end

  it "should have a user box with link to wikis list" do
    helper.stub(:current_user).and_return(mock_admin_user(:has_access_to_any_wikis? => true, :wikis => [mock_wiki, mock_wiki]))
    helper.user_box.should =~ (/Wikis/)
    helper.user_box.should =~ (/href="\/wikis"/)
    helper.user_box.should_not =~ (/Forum/)
  end

  it "should have a user box with one forum link" do
    helper.stub(:current_user).and_return(mock_admin_user(:has_access_to_any_forums? => true, :forums => [mock_forum]))
    helper.user_box.should =~ (/Forum/)
    helper.user_box.should =~ (/href="\/forums\/#{mock_forum.id}"/)
    helper.user_box.should_not =~ (/Wiki/)
  end

  it "should have a user box with link to forums list" do
    helper.stub(:current_user).and_return(mock_admin_user(:has_access_to_any_forums? => true, :forums => [mock_forum, mock_forum]))
    helper.user_box.should =~ (/Forums/)
    helper.user_box.should =~ (/href="\/forums"/)
    helper.user_box.should_not =~ (/Wiki/)
  end

  it "should give a list of images" do
    Dir.stub(:[]).and_return(['imageb.png', 'imagea.png', 'imagec.png'])
    helper.images_list.should == ['imagea.png', 'imageb.png', 'imagec.png']
  end

  it "should give a list of layouts" do
    Dir.stub(:[]).and_return(['basic.html.erb', 'awesome.html.erb'])
    helper.theme_layouts_list.should == ['awesome', 'basic']
  end
  
  it "should return a list of uniq filenames" do
    files = ["somefile.js", "some_engine/somefile.js", "other.js"]
    helper.uniq_filenames(files).should eql [files[0], files[2]]
  end
end
