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
end
