require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifier do
  def sent
    ActionMailer::Base.deliveries.first
  end

  before(:each) do
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.default_url_options[:host] = 'localhost'
  end

  it "should send password reset instructions" do
    user = stub_model(User, :id => 37, :email => "test@test.com", :perishable_token => 'blah')
    Notifier.deliver_password_reset_instructions user
    sent.subject.should == 'Password Reset Instructions'
    sent.body.should =~ /A request to reset your password has been made./
    sent.body.should =~ /\/password_resets\/blah\/edit/
  end

  it "should send new user information to admins" do
    admin = stub_model(User, :id => 1, :email => "admin@test.com")
    User.stub(:find_admins).and_return([admin])
    new_user = stub_model(User, :id => 37, :first_name => "Jack", :last_name => "Jones")
    Notifier.deliver_user_created new_user
    sent.subject.should == "New user registered: Jack Jones"
    sent.to.should == ["admin@test.com"]
    sent.body.should =~ /A new user has registered/
    sent.body.should =~ /\/users\/37\/edit/
  end
end
