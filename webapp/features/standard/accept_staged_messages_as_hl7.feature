Feature: Accept Staged Messages as HL7

  To more easily associate cases w/ lab results
  The system needs to be able to electronically accept lab orders as HL7

  Scenario: Entering an ARUP HL7 into a web form
    Given I am logged in as a super user
    
    When I visit the staged message new page
    And I type the "ARUP_1" message into "staged_message_hl7_message"
    And I press "Create"
    
    Then I should see "Staged message was successfully created"

  Scenario: Viewing an HL7 2.5.x message
    Given I am logged in as a super user
    And I have the staged message "IHC_1"
    
    When I visit the staged message show page
    
    Then I should see value "Covell, Daren L" in the message header
    And  I should see value "IHC-LD" in the message header

 Scenario: Viewing HL7 w/ multiple tests
   Given I am logged in as a super user
   And I have the staged message "ARUP_2"
   
   When I visit the staged message show page

   Then I should see value "HIV-1 Antibody Confirm, Western Blot" under label "Test Type"
   And I should see value "Negative" under label "Reference Range"
   
  Scenario: Posting a valid HL7 staged message
    Given I am logged in as a super user
    When I post the "ARUP_1" message directly to "staged_messages"
    Then I should receive a 200 response

