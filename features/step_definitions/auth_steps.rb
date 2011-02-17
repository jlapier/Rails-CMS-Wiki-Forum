Given /I am logged in as "([^"]*)" user "([^"]*)"/ do |type, username|
  steps %Q{
    Given a "#{type}" user "#{username}"
    When I go to the login page
    And I fill in "Username" with "#{username}"
    And I fill in "Password" with "test-pass"
    And I press "Login"
    Then I should see "Login successful!"
  }
end

Given /a "([^"]*)" user "([^"]*)"/ do |type, username|
  User.create!({
    :login => username,
    :email => "#{username}@test.com",
    :password => 'test-pass',
    :password_confirmation => 'test-pass',
    :first_name => username.capitalize,
    :last_name => username.reverse.capitalize,
    :is_admin => type == 'admin'
  })
  User.count.should > 0
end
