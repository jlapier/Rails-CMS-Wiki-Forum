Then /^the post "([^"]*)" should be (private|public)$/ do |title, expected|
  Blog::Post.find_by_title(title).published.should eq (expected == 'public')
end

Given /^the post "([^"]*)" has a revision history$/ do |title|
  blog_post = Blog::Post.find_by_title(title)
  blog_post.should_not be_nil
  txt = "Some initial content."
  blog_post.update_attribute(:body, txt)
  blog_post.revise!
  blog_post.update_attribute(:body, "#{txt} Some added content.")
  blog_post.revise!
  blog_post.revisions.count.should > 0
end