require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {
      :login => 'test', :email => 'test@test.com',
      :password => '12345678', :password_confirmation => '12345678'
    }
  end

  it "should create a new user given valid attributes" do
    User.create!(@valid_attributes)
  end

  it "should save the user_defined_fields" do
    u = User.create!(@valid_attributes)
    u.update_attributes! :user_defined_fields => { "role"=>"Director", "agency"=>"CIA", "state"=>"CT"}
    u.user_defined_fields['role'].should be_kind_of(String)
    u.user_defined_fields['role'].should == "Director"
    u_again = User.find u.id
    u_again.user_defined_fields['role'].should be_kind_of(String)
    u_again.user_defined_fields['role'].should == "Director"
  end

  it "should have access to wikis based on groups" do
    wiki1 = Wiki.create!(:name => "A test wiki 1")
    wiki2 = Wiki.create!(:name => "A test wiki 2")
    wiki_user_group = UserGroup.new :name => "Wiki Access", 
      :wiki_access => { wiki1.id.to_s => "read", wiki2.id.to_s => "write" }
    u = User.create!(@valid_attributes)
    u.stub!(:user_groups).and_return([wiki_user_group])
    u.group_access(wiki1).should == 'read'
    u.group_access(wiki2).should == 'write'
    assert u.has_read_access_to?(wiki1)
    assert !u.has_write_access_to?(wiki1)
    assert u.has_read_access_to?(wiki2)
    assert u.has_write_access_to?(wiki2)
    assert u.has_access_to_any_wikis?
    assert !u.has_access_to_any_forums?
  end

  it "should have access to forums based on groups" do
    forum1 = Forum.create!(:name => "A test forum 1")
    forum2 = Forum.create!(:name => "A test forum 2")
    forum_user_group = UserGroup.new :name => "Forum Access",
      :forum_access => { forum1.id.to_s => "read", forum2.id.to_s => "write" }
    u = User.create!(@valid_attributes)
    u.stub!(:user_groups).and_return([forum_user_group])
    u.group_access(forum1).should == 'read'
    u.group_access(forum2).should == 'write'
    assert u.has_read_access_to?(forum1)
    assert !u.has_write_access_to?(forum1)
    assert u.has_read_access_to?(forum2)
    assert u.has_write_access_to?(forum2)
    assert u.has_access_to_any_forums?
    assert !u.has_access_to_any_wikis?
  end
end
