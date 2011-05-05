Feature: Event calendar

  Background: I am logged in
    Given I am logged in as "admin" user "admin"

  Scenario: create a new event spanning multiple days
    When I follow "Site Admin"
    And I follow "Manage Events"
    And I follow "Create New Event"
    And I fill in "Name" with "Some New Event"
    And I fill in "Event type" with "Seminar"
    And I fill in "Start date" with "10/14/2010"
    And I fill in "End date" with "10/17/2010"
    And I fill in "Facilitators" with "Jonathan Wizzlepod, DSM NPSO"
    And I fill in "Presenters" with "Jane Doe, Professor Statistical Analysis UO"
    And I fill in "Location" with "Eugene, Oregon"
    And I fill in "Description" with "There will be 4 speakers during 8 hours..."
    And I press "Create Event"
    Then I should see "Event was successfully created."

  Scenario: create a new event w/out an explicit end date
    Given I am on the new event page
    When I fill in "Name" with "Some implied event ending"
    And I fill in "Event type" with "Conference"
    And I select "11" from "event[start_time(4i)]"
    And I select "30" from "event[start_time(5i)]"
    And I fill in "Start date" with "02/26/2011"
    And I press "Create Event"
    Then I should see "Event was successfully created."
    And I should see "Some implied event ending (Conference)"
    And I should see "Date: Saturday, February 26 2011"
    And I should see "Time: 02:30 PM - 03:30 PM Eastern / 01:30 PM - 02:30 PM Central / 12:30 PM - 01:30 PM Mountain / 11:30 AM - 12:30 PM Pacific"

  Scenario: create a new event w/ only an explicit start date
    Given I am on the new event page
    When I fill in "Name" with "Some implied start and end time"
    And I fill in "Event type" with "Meeting"
    And I fill in "Start date" with "03/04/2011"
    And I press "Create Event"
    Then I should see "Event was successfully created."
    And I should see "Some implied start and end time"
    And I should see "Date: Friday, March 04 2011"
    And I should see "Time: 09:00 AM - 10:00 AM Eastern / 08:00 AM - 09:00 AM Central / 07:00 AM - 08:00 AM Mountain / 06:00 AM - 07:00 AM Pacific"    

  Scenario: update a multi day event
    Given I am on the event page for "Editable Event"
    And I follow "edit" within "div.event"
    And I fill in "Name" with "Updated Event"
    And I press "Update Event"
    Then I should see "Event was successfully updated."

  Scenario: update a single day event
    Given I am on the event page for "Linkable Event"
    And I follow "edit" within "div.event"
    And I fill in "Start date" with "02/23/2011"
    And I fill in "End date" with "02/23/2011"
    And I select "Pacific Time (US & Canada)" from "Timezone"
    And I press "Update Event"
    Then I should be on the event page for "Linkable Event"
    And I should see "Time: 09:00 AM - 10:00 AM Eastern / 08:00 AM - 09:00 AM Central / 07:00 AM - 08:00 AM Mountain / 06:00 AM - 07:00 AM Pacific"

  Scenario: delete an event
    Given I am on the event page for "Editable Event"
    And I follow "delete" within "div.event"
    Then I should be on the events page

  Scenario: deleting then restoring an event
    Given I am on the event page for "Restorable Event"
    Then I should see "Time: 09:00 AM - 10:00 AM Eastern / 08:00 AM - 09:00 AM Central / 07:00 AM - 08:00 AM Mountain / 06:00 AM - 07:00 AM Pacific"
    And I follow "delete"
    Then I should be on the events page
    When I go to the manage events page
    And I follow "Browse Deleted Events"
    Then I should be on the event revisions page
    And I should see "Restorable Event"
    And I should see "2011"
    And I should see "February"
    And I should see "Fri 4th"
    When I follow "restore"
    Then I should be on the event page for "Restorable Event"
    And I should see "Date: Friday, February 04 2011"
    And I should see "Time: 09:00 AM - 10:00 AM Eastern / 08:00 AM - 09:00 AM Central / 07:00 AM - 08:00 AM Mountain / 06:00 AM - 07:00 AM Pacific"