# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/spec_helper'
require 'date'
 
describe 'form builder patient-level followups for contact events' do
  
  #  $dont_kill_browser = true

  fields = [{:name => 'Contact last name', :label => "//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_last_name')]", :entry_type => 'type', :fu_value => get_unique_name(1), :no_fu_value => get_unique_name(1)},
    {:name => 'Contact first name', :label => "//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_first_name')]", :entry_type => 'type',  :fu_value => get_unique_name(1), :no_fu_value => get_unique_name(1)},
    {:name => 'Contact middle name', :label => "//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_middle_name')]", :entry_type => 'type',  :fu_value => get_unique_name(1), :no_fu_value => get_unique_name(1)},
    {:name => 'Contact age', :label => "//div[@id='demographic_tab']//div[@id='person_form']//input[contains(@id, '_approximate_age_no_birthday')]", :entry_type => 'type', :fu_value => '24', :no_fu_value => '44'},
    {:name => 'Contact birth gender', :label => "//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_birth_gender_id')]", :entry_type => 'select', :code => 'Code: Female (gender)', :fu_value => 'Female', :no_fu_value => 'Male'},
    {:name => 'Contact ethnicity', :label => "//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_ethnicity_id')]", :entry_type => 'select', :code => 'Code: Hispanic or Latino (ethnicity)', :fu_value => 'Hispanic or Latino', :no_fu_value => 'Not Hispanic or Latino'},
    {:name => 'Contact primary language', :label => "//div[@id='demographic_tab']//div[@id='person_form']//select[contains(@id, '_primary_language_id')]", :entry_type => 'select', :code => 'Code: English (language)', :fu_value => 'English', :no_fu_value => 'Japanese'}
  ]                                                  
  
  data_types = [{:name => 'Single line text', :values => nil, :answer => get_unique_name(5), :entry_type => "type"},
    {:name => 'Multi-line text', :values => nil, :answer => get_unique_name(5), :entry_type => "type"},
    {:name => 'Drop-down select list', :values => ["Always","Sometimes","Never"], :answer => "Never", :entry_type => "select"},
    {:name => 'Radio buttons', :values => ["Yes","No","Maybe"], :answer_code => "3", :answer => "Maybe", :entry_type => "radio"},
    {:name => 'Checkboxes', :values => ["Pink","Red","Purple"], :answer_code => "2", :answer => "Red", :entry_type => "check"},
    {:name => 'Date', :values => nil, :answer => "2008-12-24", :entry_type => "type"},
    {:name => 'Phone Number', :values => nil, :answer => "555-555-5555", :entry_type => "type"}    
  ]
  
  fields.each do |test|  
    disease_name_text = get_random_disease()
    jurisdiction_text = get_random_jurisdiction
    form_name = DateTime.now.to_s[0..15] + " " + disease_name_text
    inv_question_pre = get_unique_name(1) + " "
        
    it "should create a form to add follow-up questions to" do  
      event_type = "Contact event"
      create_new_form_and_go_to_builder(@browser, form_name, disease_name_text, jurisdiction_text, event_type).should be_true
    end
    
    it "should create a contact follow-up container" do
      cmr_last_name = get_unique_name(1) + " cpl_f"
      contact_last_name = get_unique_name(1) + " cpl_f"    
      add_core_follow_up_to_view(@browser, "Default View", test[:code].nil? ? test[:fu_value] : test[:code], test[:name]).should be_true
    end
    
    data_types.each do |data_type|
      follow_up_question = inv_question_pre + data_type[:name]
      it "should create a follow up question: " + follow_up_question do       
        add_question_to_follow_up(@browser, test[:name], {:question_text => follow_up_question, :data_type => data_type[:name], :short_name => get_random_word}).should be_true
        if data_type[:values] != nil 
          add_value_set_to_question(@browser,
            follow_up_question,
            "Value Set " + get_unique_name(2),
            [{ :name => data_type[:values][0] }, { :name => data_type[:values][1] }, { :name => data_type[:values][2] }]
          ).should be_true
        end
      end
    end
 
    it "should publish the form" do
      publish_form(@browser).should be_true
    end
  
    it "should create a cmr with a contact" do
      create_basic_investigatable_cmr(@browser, (get_unique_name(1))[0..18], disease_name_text, jurisdiction_text)
      edit_cmr(@browser).should be_true  
      
      add_contact(@browser, {:last_name => get_unique_name(1), :first_name => "Contact", :disposition => "Unable to locate"})
      save_cmr(@browser).should be_true
    end
    
    it "should add all the followup questions when #{test[:name]} is assigned the value #{test[:fu_value]}" do  
      @browser.click("//ul[@id='tabs']/li[4]/a/em")
      @browser.click("edit-contact-event")
      @browser.wait_for_page_to_load($load_time)
      
      @browser.is_text_present(form_name).should be_true
      
      data_types.each do |data_type|
        follow_up_question = inv_question_pre + data_type[:name]
        @browser.is_text_present(follow_up_question).should be_false
      end
          
      case test[:entry_type]
      when 'type' 
        @browser.type(test[:label], test[:fu_value])
      when 'click' 
        @browser.click(test[:label], test[:fu_value])
      when 'select' 
        @browser.select(test[:label], test[:fu_value])
      end
      
      @browser.click("//ul[@id='tabs']/li[5]/a/em")
      @browser.is_text_present(form_name).should be_true
      sleep 2 #Giving the investigator form questions time to show up
      
      data_types.each do |data_type|
        follow_up_question = inv_question_pre + data_type[:name]
        @browser.is_text_present(follow_up_question).should be_true
      end
    end
    
    it "should remove all the investigator questions when the value is changed to #{test[:no_fu_value]}" do         
      case test[:entry_type]
      when 'type' 
        @browser.type(test[:label], test[:no_fu_value])
      when 'click' 
        @browser.click(test[:label], test[:no_fu_value])
      when 'select' 
        @browser.select(test[:label], test[:no_fu_value])
      end
      
      @browser.click("//ul[@id='tabs']/li[5]/a/em")
      @browser.is_text_present(form_name).should be_true
      sleep 2 #Giving the investigator form questions time to show up
      
      data_types.each do |data_type|
        follow_up_question = inv_question_pre + data_type[:name]
        @browser.is_text_present(follow_up_question).should be_false
      end
    end
    
    it "should show the form and questions when the value is changed back to #{test[:fu_value]}" do  
      case test[:entry_type]
      when 'type' 
        @browser.type(test[:label], test[:fu_value])
      when 'click' 
        @browser.click(test[:label], test[:fu_value])
      when 'select' 
        @browser.select(test[:label], test[:fu_value])
      end
      
      @browser.click("//ul[@id='tabs']/li[5]/a/em")
      @browser.is_text_present(form_name).should be_true
      sleep 2 #Giving the investigator form questions time to show up
      
      data_types.each do |data_type|
        follow_up_question = inv_question_pre + data_type[:name]
        @browser.is_text_present(follow_up_question).should be_true
      end
      
      # This isn't strictly necessary since nothing has changed... but the next tests won't work other wise...
      save_contact_event(@browser).should be_true
    end
    
    data_types.each do |data_type|
      follow_up_question = inv_question_pre + data_type[:name]
      it "should save values for #{follow_up_question}" do 
        edit_cmr(@browser)
        @browser.click("//ul[@id='tabs']/li[5]/a/em")
        @browser.is_text_present(follow_up_question).should be_true    
        case data_type[:entry_type]   
        when 'select'
          answer_multi_select_investigator_question(@browser, follow_up_question, data_type[:answer]).should be_true
          save_contact_event(@browser).should be_true
          @browser.is_text_present(data_type[:answer]).should be_true
        when 'type'
          answer_investigator_question(@browser, follow_up_question, data_type[:answer]).should be_true
          save_contact_event(@browser).should be_true
          @browser.is_text_present(data_type[:answer]).should be_true
        when 'check'
          answer_check_investigator_question(@browser, follow_up_question, data_type[:answer_code]).should be_true
          save_contact_event(@browser).should be_true
          @browser.is_text_present(data_type[:answer]).should be_true 
        when 'radio'
          answer_radio_investigator_question(@browser, follow_up_question, data_type[:answer_code]).should be_true
          save_contact_event(@browser).should be_true
          @browser.is_text_present(data_type[:answer]).should be_true 
        end       
      end
    end
  end
end
