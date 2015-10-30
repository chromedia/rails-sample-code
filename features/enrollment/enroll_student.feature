Feature: Online enrollment for students

  Background:
    Given a review season exists

  Scenario: Full package enrollment
    Given I am on the enrollment package type page
    When I select "standard_package"
    * I press the "Next" button
    * I fill up these student information
      | Field        | Value          | Type   |
      | First Name   | John           | text   |
      | Last Name    | dela Cruz      | text   |
      | Birthdate    | Nov 10, 1992   | text   |
      | Sex          | Female         | select |
      | Civil Status | Married        | select |
      | Address      | Palo, Leyte,   | text   |
      | Contact No   | 123-4567       | text   |
      | Email        | john@gmail.com | text   |
    * I press the "Next" button
    * I fill up these student information
      | Field         | Value                       | Type   |
      | Last Attended | Cebu Institute of Medicine  | text   |
      | College Year  | 2014                        | select |
      | HS            | Bethel International School | text   |
      | HS Year       | 2010                        | select |
      | Elem          | Bethel International School | text   |
      | Elem Year     | 2000                        | select |
    * I press the "Next" button
    * I press the "Next" button
    * I press the "I Agree" button
    * I press the "Skip" button
    * I press the "Done" button
    Then I should be on the homepage
    * The student should be for confirmation

  Scenario: No package selected
    Given I am on the enrollment package type page
    When I press the "Next" button
    Then I should still be on the enrollment package page

  Scenario: Missing personal information
    Given I am on the enrollment package type page
    When I select "standard_package"
    * I press the "Next" button
    * I press the "Next" button
    Then I should see 6 errors


  Scenario: Missing educational information
    Given I am on the enrollment package type page
    When I select "standard_package"
    * I press the "Next" button
    * I fill up these student information
      | Field        | Value          | Type   |
      | First Name   | John           | text   |
      | Last Name    | dela Cruz      | text   |
      | Birthdate    | Nov 10, 1992   | text   |
      | Sex          | Female         | select |
      | Civil Status | Married        | select |
      | Address      | Palo, Leyte,   | text   |
      | Contact No   | 123-4567       | text   |
      | Email        | john@gmail.com | text   |
    When I press the "Next" button
    * I press the "Next" button
    Then I should see 5 errors


  Scenario Outline: Enrollment via pricing page
    Given I am on the pricing page
    When I select the "<Package>" package
    Then I should skip the enrollment package step
    * should be enrolled for the "<Package>" package

  Examples:
    | Package          |
    | Final Coaching   |
    | Standard Package |
    | Double Review    |

  Scenario: Invalid package type in url
    Given I skip the enrollment package step with an invalid package type
    Then I should see an invalid package type error