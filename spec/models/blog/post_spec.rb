require 'spec_helper'

associations = {
  :belongs_to => %w(author editing_user modifying_user category)
}

describe Blog::Post do
  
  spec_associations(associations, :class => Blog::Post)
  
  describe "valid instance" do
    let(:post){ Blog::Post.new :title => 'Yay!', :body => 'Longer yay!'}
    before(:each) do
      post.author_id = 1
    end
    %w(title author_id).each do |attr_name|
      it "has a #{attr_name}" do
        post.send "#{attr_name}=", nil
        post.should_not be_valid
        post.should have(1).error_on(attr_name)
      end
    end
    
    it "has a unique title" do
      post.save!
      p = Blog::Post.new(:title => 'Yay!')
      p.should_not be_valid
      p.should have(1).error_on(:title)
    end
  end
  
  describe "#toggle_published" do
    it "publishes unpublished posts" do
      post = Blog::Post.new
      post.toggle_published
      post.published.should be_true
    end
    it "unpublishes published posts" do
      post = Blog::Post.new
      post.published = true
      post.toggle_published
      post.published.should be_false
    end
  end
end


# == Schema Information
#
# Table name: blog_posts
#
#  id                 :integer         not null, primary key
#  author_id          :integer
#  category_id        :integer
#  editing_user_id    :integer
#  modifying_user_id  :integer
#  title              :string(255)
#  body               :text
#  published          :boolean         default(FALSE)
#  started_editing_at :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

