Then /I should see the current month and year/ do
  steps %Q{
    Then I should see "#{Date.current.strftime('%B')}"
    And I should see "#{Date.current.year}"
  }
end
