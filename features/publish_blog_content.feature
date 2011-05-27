Feature: Publish blog content
  In order to make blog content available to the public
  As an admin user
  I want to publish blog content

  Scenario: publish a post
    Given I am logged in as "admin" user "admin"
    And I am on the blog post page for "Pending Post"
    When I follow "Publish"
    Then I should see "Published post: Pending Post"
    And the post "Pending Post" should be public

  Scenario: receive some notification when published posts are revised
    Given one or more admin users exist
    When a published post is revised
    Then all admin users should receive an email notification with a link to the post
    
  Scenario: revert a post to previous version
    Given I am logged in as "admin" user "admin"
    And I am viewing the post "Updated Post"
    When I press "Review Changes"
    Then I should see the previous version
    When I press "Revert"
    Then I should see "Post reverted to version _x_."