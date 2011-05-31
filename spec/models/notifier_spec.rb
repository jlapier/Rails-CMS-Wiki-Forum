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
    Notifier.password_reset_instructions(user).deliver
    sent.subject.should == 'Password Reset Instructions'
    sent.body.should =~ /A request to reset your password has been made./
    sent.body.should =~ /\/password_resets\/blah\/edit/
  end

  it "should send new user information to admins" do
    admin = stub_model(User, :id => 1, :email => "admin@test.com")
    User.stub(:find_admins).and_return([admin])
    new_user = stub_model(User, :id => 37, :first_name => "Jack", :last_name => "Jones")
    Notifier.user_created(new_user).deliver
    sent.subject.should == "New user registered: Jack Jones"
    sent.to.should == ["admin@test.com"]
    sent.body.should =~ /A new user has registered/
    sent.body.should =~ /\/users\/37\/edit/
  end
  
  it "should send blog post published notifications to admins" do
    admin = stub_model(User, :id => 1, :email => "admin@test.com")
    user = mock_model(User, :first_name => "Johnny", :last_name => "Test")
    User.stub(:find_admins).and_return([admin])
    post = mock_model(Blog::Post, {:title => 'Post Title', :body => 'Some really long heady stuff that will be shorter in this test.'})
    Notifier.published_blog_post_updated(post, user).deliver
    
    sent.subject.should eq "Published Blog Post Updated [Post Title]"
    sent.to.should eq ["admin@test.com"]
    sent.body.should =~ /Some really long heady stuff that will be shorter in this test\./
    sent.body.should =~ /Johnny Test published the blog post: Post Title/
    sent.body.should =~ /dashboard\/blog/
    sent.body.should =~ /blog\/posts\/#{post.id}/
  end
end
