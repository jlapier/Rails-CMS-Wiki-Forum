Feature: Read blog content
  In order to learn new stuff and kill time
  As a random user
  I want to navigate and consume blog content in various ways
  
  Background: anonymous user is reading blog posts
    Given I am viewing the blog home page
  
  Scenario: consume an rss subscription to all blog posts
    When I follow "Follow this blog"
    Then I should be subscribed
    And I should receive posts (new and updated)
    And I should receive post comments
  
  Scenario: consume an rss subscription to a specific blog post
    When I follow "Follow this post"
    Then I should be subscribed
    And I should receive this post
    And I should receive updates to this post
    And I should receive comments to this post
    
  Scenario: consume an rss subscription to a specific blog author
    When I follow "Follow this author"
    Then I should be subscribed
    And I should receive all posts by this author
    And I should receive updates to any posts by this author
    And I should receive comments to any posts by this author
    
  Scenario: easily view sibling sub-categories of currently selected category
    When I follow "Top Level Category"
    Then I should see all the posts in the category "Top Level Category"
    And I should see links to all the sub-categories in the category "Top Level Category"