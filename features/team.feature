Feature: Managing Teams
  Scenario: Adding a new Team
    Given I am on the teams page
    And queues and topics are configured
    When An agent creates a new team named "TeamName" with product "TeamProduct" and region "TeamRegion"
    Then I should be on team page
    And I should see "TeamName"
    And the team page has my info
    And I should see a flash message with "Team created successfully"
    And I click "Teams"
    And I should see "TeamProduct"
    And I should see "TeamRegion"

  Scenario: Updating existing team
    Given I am in the "TeamName" team with "Test User" user
    And I am on the teams page
    When I update team "TeamName" with name "NewName" and product "NewProduct" and region "NewRegion"
    And I should see a flash message with "Team updated successfully"
    And I click "Teams"
    Then I should see "NewName"
    And I should see "NewProduct"
    And I should see "NewRegion"

  Scenario: Updating existing team when the user is not in it
    Given the "TeamName" team
    And I am on the "TeamName" team page
    Then I should not see "Edit this team"

  @javascript
  Scenario: Adding an user to the team
    Given I am in the "TeamName" team with "Test User" user
    And a LDAP user "Test Ldap User"
    And I am on the teams page
    When I click on "Edit"
    And I search for "Test"
    Then I should see dropdown with "Test Ldap User"

    When I select "Test Ldap User" from dropdown
    And I save team
    Then team should contain "Test Ldap User"

  @javascript
  Scenario: Removing an user from the team
    Given I am in the "TeamName" team with "Test User" user
    And I am on the teams page
    When I click on "Edit"
    And I click on remove cross near "Test User"
    And I save team
    Then team should not contain "Test User"

  Scenario: Show Create a new jenkins server in the team page
    Given I am in the "TeamName" team
    And I am on the teams page
    When I click "TeamName"
    Then I should see "Jenkins server"
    And I should see "Create a new jenkins server"

  Scenario: Show the existing jenkins server in the team page
    Given I am in the "TeamName" team
    And the team has a Jenkins server
    And I am on the teams page
    When I click "TeamName"
    Then I should see "Jenkins server"
    And I should see the Jenkins server name
    And I should see the url of the Jenkins server

  Scenario: Show EC2 instances in the team page
    Given I have an EC2 instance in the team
    When I am on the team page
    Then I should see a short table with the instance

  Scenario: Inactive teams
    Given the "TeamName" team is inactive
    And I am on the teams page
    Then I should not see "TeamName"

  Scenario: Show team page from Environment page
    Given I am in the "TeamName" team with "username" user
    And "TeamName" team has an "INT" environment "TEST_INT"
    When I am on environment page
    And I click on "TeamName Team"
    Then I should see "Team Members"
    And I should see "Environment Control"
    And I should see "EC2 Instance Control"
