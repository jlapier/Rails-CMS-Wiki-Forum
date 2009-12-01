require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserGroup do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    UserGroup.create!(@valid_attributes)
  end

  it "should drop a bunch of users from membership" do
    ug = UserGroup.create!(@valid_attributes)
    users = (1..4).map do |u|
      User.create!( { :login => "test#{u}", :email => "test#{u}@test.com",
        :password => '12345678', :password_confirmation => '12345678'
      })
    end
    ug.users = users
    ug.save
    ug = UserGroup.find(ug.id)
    ug.users.size.should == 4
    user_ids_as_strings_like_you_would_get_from_a_post_request = [users[0].id.to_s, users[1].id.to_s]
    assert ug.drop_users(user_ids_as_strings_like_you_would_get_from_a_post_request)
    ug = UserGroup.find(ug.id)
    ug.users.size.should == 2
    ug.users.should_not include(users[0])
    ug.users.should_not include(users[1])
  end
end
