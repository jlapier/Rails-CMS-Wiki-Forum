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

  it "should have access based on groups" do
    wiki_reader_user_group = UserGroup.new :name => "Wiki Reader Access", :special => [0]
    u = User.create!(@valid_attributes)
    u.stub!(:user_groups).and_return([wiki_reader_user_group])
    assert u.has_access_to?('wiki')
    assert !u.has_access_to?('forum')
    assert u.has_group_access?('Wiki Reader')
    assert !u.has_group_access?('Wiki Editor')
    assert !u.has_group_access?('I make up good stuff')
  end
end
