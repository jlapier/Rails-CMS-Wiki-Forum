Feature: Create blog content
  In order to submit content for publication
  As a registered user
  I want a simple interface to create blog posts
  
  Background: logged in with a 'writer' account
    Given I am logged in as "writer" user "john"

  Scenario: write a new post
    Given I am on the new blog post page
    When I fill in "Title" with "Get the most from all your data"
    And I select "Some Wiki-provided Category" from "Category"
    And I press "Save"
    Then I should see "Saved post: Get the most from all your data"
    And I should see "Publication is pending moderator approval"
    And I should be on the edit blog post page for "Get the most from all your data"
    And the post "Get the most from all your data" should be private
    
  Scenario: update a published post
    Given I am on the edit blog post page for "Published Post"
    When I fill in "blog_post[body]" with "[Update] - A few things have changed since my original post..."
    And I press "Save"
    Then I should see "Updated post: Published Post"
    And I should be on the blog post page for "Published Post"
