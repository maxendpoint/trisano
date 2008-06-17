require File.dirname(__FILE__) + '/spec_helper'
  
describe "Using Form Builder to manipulte core-data fields" do
  before(:all) do
    @form_name = NedssHelper.get_unique_name(4)
  end
  
  it "should create a form using core data fields" do
    pending "Won't work until core data fields through form_builder gets re-visited"
    @browser.open "/nedss/"
    @browser.click "link=Forms"
    @browser.wait_for_page_to_load($load_time)

    @browser.click "link=New form"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "form_name", @form_name
    @browser.select "form_disease_id", "label=Amebiasis"
    @browser.click "form_submit"
    @browser.wait_for_page_to_load($load_time)

    @browser.click "link=Form Builder"
    @browser.wait_for_page_to_load($load_time)

    @browser.click "link=Add section to tab"
    wait_for_element_present("new-section-form") 
    @browser.type "section_element_name", "Section 1"
    @browser.click "section_element_submit"
    wait_for_element_not_present("new-section-form")

    @browser.click "link=Add a core data element"
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "Middle Name:"
    @browser.select "question_element_question_attributes_core_data_attr", "label=Patient Middle Name"
    @browser.click "question_element_submit"
    wait_for_element_not_present("new-question-form")

    @browser.click "link=Add a core data element"
    wait_for_element_present("new-question-form")
    @browser.type "question_element_question_attributes_question_text", "DOD:"
    @browser.select "question_element_question_attributes_core_data_attr", "label=Patient Date of Death"
    @browser.click "question_element_submit"
    wait_for_element_not_present("new-question-form")

    @browser.click "//input[@value='Publish']"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("Form was successfully published").should be_true
  end

  it "Should create a new CMR" do
    pending "Won't work until core data fields through form_builder gets re-visited"
    @browser.click "link=New CMR"
    @browser.wait_for_page_to_load($load_time)
    @browser.type "event_active_patient__active_primary_entity__person_last_name", "Green"
    @browser.type "event_active_patient__active_primary_entity__person_first_name", "Joe"
    @browser.click "//ul[@id='tabs']/li[2]/a/em"
    @browser.select "event_disease_disease_id", "label=Amebiasis"
    @browser.click "//ul[@id='tabs']/li[6]/a/em"
    @browser.select "event_event_status_id", "label=Under Investigation"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("CMR was successfully created").should be_true
  end

  it "should render and save core-data fields" do
    pending "Won't work until core data fields through form_builder gets re-visited"
    @browser.click "edit_cmr_link"
    @browser.wait_for_page_to_load($load_time)
    @browser.click "//ul[@id='tabs']/li[8]/a/em"
    @browser.type "event_active_patient__active_primary_entity__person__middle_name", "Quincy"
    @browser.type "event_active_patient__active_primary_entity__person__date_of_death", "02-28-1950"
    @browser.click "event_submit"
    @browser.wait_for_page_to_load($load_time)
    @browser.is_text_present("CMR was successfully updated").should be_true
  end

  it "should maintain values on re-edit" do
    pending "Won't work until core data fields through form_builder gets re-visited"
    @browser.click "edit_cmr_link"
    @browser.wait_for_page_to_load($load_time)
    @browser.click "//ul[@id='tabs']/li[7]/a/em"
    @browser.get_value("event_active_patient__active_primary_entity__person__middle_name").should eql("Quincy")
    @browser.get_value("event_active_patient__active_primary_entity__person__date_of_death").should eql("1950-02-28")
  end
end
