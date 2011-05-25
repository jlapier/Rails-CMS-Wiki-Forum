Feature: Create blog comment
  In order to participate in the discussion
  As a blog reader
  I want to leave comments

  Scenario: leave a comment as an anonymous user
    Given I am on the blog post page for "Published Post"
    When I fill in "Name" with "Sam Jones"
    And I fill in "Email" with "sam.jones@example.com"
    And I fill in "Comment" with "Great write-up. What do you think about x?"
    And I press "Submit Comment"
    Then I should see "Comment saved!"
    And I should be on the blog post page for "Published Post"
  
  Scenario: leave a comment as a logged in user
    Given I am viewing the post "Published Post"
    When I fill in "Comment" with "I'm having trouble wrapping my head around y."
    And I press "Save"
    Then I should see "I'm having trouble wrapping my head around y."
    And I should be on the post page for "Published Post"