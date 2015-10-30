Feature: Disable enrollment and other particulars when there is no ongoing review season
  Background:
    Given no ongoing review season exists

  Scenario: Finding the enroll link at header
    Given I am on the home page
    Then I should not be able to see the enroll link

  Scenario: Force enrollment via url
    Given I am on the enrollment package type page
    Then I should see "There is no ongoing review season as of this moment."

  Scenario: Enrollment at pricing page
    Given I am on the pricing page
    Then I should not be able to see the enroll link
    * I should see "There is no ongoing review season as of this moment."

