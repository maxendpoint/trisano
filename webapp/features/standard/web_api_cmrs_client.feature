Feature: Web API Cmrs Client

  To create and modify morbidity reports programmatically
  An interface is needed that can be integrated into code

  Scenario: Create CMR
    When I visit the cmrs new page
    
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][first_name]" with "David"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][middle_name]" with "Ryan"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][last_name]" with "Black"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_date]" with "11-10-1980"
    And I fill out the form field "morbidity_event[parent_guardian]" with "Gerard Black"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][approximate_age_no_birthday]" with "28"
    And I select "Male" from "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_gender_id]" 
    And I select "Unknown" from "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][ethnicity_id]"
    And I select "White" from "morbidity_event[interested_party_attributes][person_entity_attributes][race_ids][]"
    And I select "English" from "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][primary_language_id]"
    And I fill out the form field "morbidity_event[address_attributes][street_number]" with "12"
    And I fill out the form field "morbidity_event[address_attributes][street_name]" with "East"
    And I fill out the form field "morbidity_event[address_attributes][unit_number]" with "448"
    And I fill out the form field "morbidity_event[address_attributes][city]" with "Greenville"
    And I select "Utah" from "morbidity_event[address_attributes][state_id]"
    And I select "Rich" from "morbidity_event[address_attributes][county_id]"
    And I fill out the form field "morbidity_event[address_attributes][postal_code]" with "16125"
    And I select "Home" from "morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][area_code]" with "724"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][phone_number]" with "5882300"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][extension]" with "23"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][email_addresses_attributes][1][email_address]" with "foo@bar.com"
    And I select "AIDS" from "morbidity_event[disease_event_attributes][disease_id]"
    And I fill out the form field "morbidity_event[disease_event_attributes][disease_onset_date]" with "1-1-2000"
    And I fill out the form field "morbidity_event[disease_event_attributes][date_diagnosed]" with "1-2-2000"
    And I select "Yes" from "morbidity_event[disease_event_attributes][hospitalized_id]"
    And I select "Beaver Valley Hospital" from "morbidity_event[hospitalization_facilities_attributes][0][secondary_entity_id]"
    And I fill out the form field "morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][admission_date]" with "1-3-2000"
    And I fill out the form field "morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][discharge_date]" with "1-4-2000"
    And I fill out the form field "morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][medical_record_number]" with "433"
    And I select "Yes" from "morbidity_event[disease_event_attributes][died_id]"
    And I fill out the form field "morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][date_of_death]" with "1-30-2000"
    And I select "Yes" from "morbidity_event[interested_party_attributes][risk_factor_attributes][pregnant_id]"
    And I fill out the form field "morbidity_event[interested_party_attributes][risk_factor_attributes][pregnancy_due_date]" with "1-5-2000"
    And I select "Yes" from "morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_given_yn_id]"
    And I fill out the form field "morbidity_event[interested_party_attributes][treatments_attributes][0][treatment]" with "MyTreatment"
    And I fill out the form field "morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_date]" with "1-6-2000"
    And I fill out the form field "morbidity_event[interested_party_attributes][treatments_attributes][0][stop_treatment_date]" with "1-7-2000"
    And I fill out the form field "morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][first_name]" with "Sam"
    And I fill out the form field "morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][middle_name]" with "R"
    And I fill out the form field "morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][last_name]" with "Burke"
    And I select "Home" from "morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][entity_location_type_id]"
    And I fill out the form field "morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][area_code]" with "703"
    And I fill out the form field "morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][phone_number]" with "2654321"
    And I fill out the form field "morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][extension]" with "808"
    # No test data yet for this
    #And I fill out the form field "morbidity_event[labs_attributes][3][place_entity_attributes][place_attributes][name]" with "Acme Lab"
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][test_type_id]" with ""
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][test_result_id]" with ""
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][result_value]" with "123"
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][units]" with "grams"
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][reference_range]" with "12-88"
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][test_status_id]" with ""
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_source_id]" with ""
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][collection_date]" with "1-9-2000"
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][lab_test_date]" with "1-10-2000"
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_sent_to_state_id]" with ""
    #And I fill out the form field "morbidity_event[labs_attributes][3][lab_results_attributes][0][comment]" with "Sample comment"
    And I fill out the form field "morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][person_attributes][first_name]" with "Jen"
    And I fill out the form field "morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][person_attributes][last_name]" with "Dubbs"
    And I select "Other" from "morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][disposition_id]"
    And I select "Other" from "morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][contact_type_id]"
    And I select "Home" from "morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]"
    And I fill out the form field "morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][area_code]" with "412"
    And I fill out the form field "morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][phone_number]" with "2652222"
    And I fill out the form field "morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][extension]" with "98"
    And I select "Yes" from "morbidity_event[interested_party_attributes][risk_factor_attributes][food_handler_id]"
    And I select "Yes" from "morbidity_event[interested_party_attributes][risk_factor_attributes][healthcare_worker_id]" 
    And I select "Yes" from "morbidity_event[interested_party_attributes][risk_factor_attributes][group_living_id]"
    And I select "Yes" from "morbidity_event[interested_party_attributes][risk_factor_attributes][day_care_association_id]"
    And I fill out the form field "morbidity_event[interested_party_attributes][risk_factor_attributes][occupation]" with "Pizza Delivery Guy"
    And I select "Unknown" from "morbidity_event[imported_from_id]"
    And I fill out the form field "morbidity_event[interested_party_attributes][risk_factor_attributes][risk_factors]" with "Bad factor"
    And I fill out the form field "morbidity_event[interested_party_attributes][risk_factor_attributes][risk_factors_notes]" with "Bad factor notes"
    And I fill out the form field "morbidity_event[other_data_1]" with "other data 1"
    And I fill out the form field "morbidity_event[other_data_2]" with "other data 2"
    And I fill out the form field "morbidity_event[reporter_attributes][person_entity_attributes][person_attributes][first_name]" with "David"
    And I fill out the form field "morbidity_event[reporter_attributes][person_entity_attributes][person_attributes][last_name]" with "Jenkins"
    And I fill out the form field "morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][area_code]" with "999"
    And I fill out the form field "morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][phone_number]" with "9999999"
    And I fill out the form field "morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][extension]" with "999"
    And I fill out the form field "morbidity_event[results_reported_to_clinician_date]" with "1-20-2000"
    And I fill out the form field "morbidity_event[first_reported_PH_date]" with "1-21-2000"
    And I select "Unknown" from "morbidity_event[lhd_case_status_id]"
    And I select "Unknown" from "morbidity_event[state_case_status_id]"
    And I select "Unknown" from "morbidity_event[outbreak_associated_id]"
    And I fill out the form field "morbidity_event[outbreak_name]" with "outbreak name"
    And I fill out the form field "morbidity_event[event_name]" with "event name"
    And I fill out the form field "morbidity_event[acuity]" with "acuity"
    And I press "Save & Exit"

    Then I should see "CMR was successfully created"