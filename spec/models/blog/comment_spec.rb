require 'spec_helper'

describe Blog::Comment do
  subject{ Blog::Comment.new }
  let(:blog_post) do
    stub_model(Blog::Post, {
      :published => true
    })
  end
  let(:current_user) do
    stub_model(User, {
      :logged_in? => false
    })
  end
  describe "commenter validation" do
    context "commenter_name and commenter_email are blank" do
      it "requires commenter_id" do
        subject.post = blog_post
        subject.body = "body"
        subject.commenter_id = 1
        subject.should be_valid
      end
    end
    context "commenter_id is blank" do
      it "requires commenter_name and commenter_email" do
        subject.post = blog_post
        subject.body = "body"
        subject.commenter_name = "Name"
        subject.commenter_email = "email@test.com"
        subject.should be_valid
      end
    end
  end
  describe "#request_approval(current_user)" do
    context "some user is logged in" do
      before(:each) do
        current_user.stub(:logged_in?){ true }
      end
      it "auto-approves the comment" do
        subject.request_approval current_user
        subject.status.should eq "approved"
      end
      it "stores the current_user.id as commenter_id" do
        subject.request_approval current_user
        subject.commenter_id.should eq current_user.id
      end
    end
    context "no user is logged in" do
      let(:current_user){ nil }
      it "forces the comment to be pending" do
        subject.status = "approved"
        subject.request_approval current_user
        subject.status.should eq "pending"
      end
    end
  end
end


# == Schema Information
#
# Table name: blog_comments
#
#  id              :integer         not null, primary key
#  post_id         :integer
#  status          :string(255)     default("pending")
#  commenter_id    :integer
#  commenter_email :string(255)
#  commenter_name  :string(255)
#  body            :text
#  created_at      :datetime
#  updated_at      :datetime
#

