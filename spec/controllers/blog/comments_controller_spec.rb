require 'spec_helper'

describe Blog::CommentsController do
  subject{ Blog::Comment.new }
  describe "'create', (:blog_comment)" do
    let(:params) do
      {
        :post_id => 1,
        :commenter_email => 'email@test.com',
        :commenter_name => 'name',
        :body => 'this is a comment'
      }
    end
    before(:each) do
      subject.stub(:save)
      Blog::Comment.stub(:new).with(params){ subject }
    end
    it "loads a new @comment" do
      post :create, :blog_comment => params
      assigns(:comment).should eq subject
    end
    it "saves the @comment" do
      subject.should_receive(:save)
      post :create, :blog_comment => params
    end
    context "save succeeds :)" do
      before(:each) do
        subject.stub(:save){ true }
      end
    end
    context "save fails :(" do
    end
  end
end
