require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

Factory.define :wiki do |wiki|
  wiki.sequence(:title) { |n| "Some wiki #{n}" }
end

Factory.define :forum do |forum|
  forum.sequence(:name) { |n| "Some forum #{n}" }
end

describe UserGroup do
  before(:each) do
    @valid_attributes = {
      :name => "some group name"
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



  it "should not give destroyed wikis" do
    wiki1 = Factory(:wiki)
    wiki2 = Factory(:wiki)
    ug = UserGroup.create!(@valid_attributes)
    ug.wiki_access = {  wiki1.id.to_s =>  "read", wiki2.id.to_s =>  "write" }
    ug.save!
    ug.wikis.should ==  {"1"=>"read", "2"=>"write"}
    wiki1.destroy
    ug = UserGroup.find ug.id
    ug.wikis.should ==  {"2"=>"write"}
  end

  it "should not give destroyed forums" do
    forum1 = Factory(:forum)
    forum2 = Factory(:forum)
    ug = UserGroup.create!(@valid_attributes)
    ug.forum_access = {  forum1.id.to_s =>  "read", forum2.id.to_s =>  "write" }
    ug.save!
    ug.forums.should ==  {"1"=>"read", "2"=>"write"}
    forum1.destroy
    ug = UserGroup.find ug.id
    ug.forums.should ==  {"2"=>"write"}
  end
end
