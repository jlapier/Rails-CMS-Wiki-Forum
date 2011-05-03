Feature: Create blog content
  In order to submit content for publication
  As a registered user
  I want a simple interface to create blog posts

  Background: non-admin (registered) user is logged in
    Given I am logged in as a non-admin user

  Scenario: write a new post
    Given I am on the new post page
    When I fill in "Title" with "Get the most from all your data"
    And I fill in "Body" with "Unquestionably the biggest challenge facing any organization today is effectively locating, managing and analysing the constant stream of data."
    And I select "Some Wiki-provided Category" from "Category"
    And I press "Save"
    Then I should see "Post saved! Publication is pending moderator review."
    And I should be on the posts page
    And the post "Get the most from all your data" should be private
    
  Scenario: update a published post
    Given I am on the edit post page for "Published Post"
    When I fill in "Body" with "[Update] - A few things have changed since my original post..."
    And I press "Save"
    Then I should see "Post updated!"
    And I should be on the posts page
    And the post "Published Post" should be public
    
  Scenario: upload a file and have a download link to the file insert itself into the post body
    Given I am on the new post page
    When I click "Upload"
    And select a file "SomeFile.doc" from my computer
    And I press "OK"
    Then I should see a publicly accessible link to "SomeFile.doc" in the post body field
