Feature: Read blog content
  In order to learn new stuff and kill time
  As a random user
  I want to navigate and consume blog content in various ways

  Background: anonymous user is reading blog posts
    Given I am on the blog posts page

  Scenario: read a blog post
    Then I should see "Some Great Title"
    And I should see "The body for Some Great Title"
    When I follow "Read more..." within "div.posts > div:nth-of-type(3)"
    Then I should be on the blog post page for "Some Great Title"

  Scenario: view all blog posts by a specific author
    When I follow "John Doe"
    Then I should be on the blog posts by "John Doe" page
    And I should not see "Some Other Title"
    And I should see "Some Great Title"

  Scenario: easily view sibling sub-categories of currently selected category
    When I have and follow "Top Level Category"
    Then I should see all the posts in the category "Top Level Category"
    And I should see links to all the sub-categories in the category "Top Level Category"