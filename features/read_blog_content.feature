Feature: Read blog content
  In order to learn new stuff and kill time
  As a random user
  I want to navigate and consume blog content in various ways
  
  Background: anonymous user is reading blog posts
    Given I am on the blog posts page
    
  Scenario: read a blog post
    Then I should see "Some Great Title"
    And I should see "The body for Some Great Title"
    When I follow "Read more..."
    Then I should be on the blog post page for "Some Great Title"
  
  Scenario: consume an rss subscription to a specific blog author
    When I subscribe to an author
    Then I should be subscribed
    And I should receive all posts by this author
    And I should receive updates to any posts by this author
    And I should receive comments to any posts by this author
    
  Scenario: easily view sibling sub-categories of currently selected category
    When I follow "Top Level Category"
    Then I should see all the posts in the category "Top Level Category"
    And I should see links to all the sub-categories in the category "Top Level Category"