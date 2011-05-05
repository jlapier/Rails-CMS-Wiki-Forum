Then /^the post "([^"]*)" should be (private|public)$/ do |title, expected|
  Blog::Post.find_by_title(title).published.should eq (expected == 'public')
end