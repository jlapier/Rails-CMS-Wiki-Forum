Feature: Publish blog content
  In order to make blog content available to the public
  As an admin user
  I want to publish blog content

  Scenario: revert a post to previous version
    Given I am logged in as "admin" user "admin"
    And the post "Pending Post" has a revision history
    And I am on the blog post page for "Pending Post"
    When I follow "Revision History"
    Then I should be on the blog post revisions page for "Pending Post"
    When I follow "Revert"
    Then I should see "Reverted to"
    And I should be on the blog post page for "Pending Post"

  Scenario: publish a post
    Given I am logged in as "admin" user "admin"
    And I am on the blog post page for "Pending Post"
    When I follow "Publish"
    Then I should see "Published post: Pending Post"
    And the post "Pending Post" should be public
