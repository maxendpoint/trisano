# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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
require 'active_support'

describe 'Adding multiple treatments to a CMR' do
  
  #$dont_kill_browser = true
  
  before(:all) do
    @browser.open "/trisano/cmrs"
    @browser.wait_for_page_to_load($load_time)
  end
  
  it "should allow multiple treatments to be saved with a new CMR" do
    display_date = 10.days.ago.strftime('%B %d, %Y')

    click_nav_new_cmr(@browser).should be_true
    @browser.type "morbidity_event_active_patient__person_last_name", "multi-treatments"
    @browser.type "morbidity_event_active_patient__person_first_name", "test"

    click_core_tab(@browser, "Clinical")
    @browser.click "link=Add a treatment"
    sleep(1)

    @browser.type "//div[@class='treatment'][1]//input[contains(@id, 'treatment_attributes__treatment')]", "Leeches" 
    @browser.type "//div[@class='treatment'][1]//input[contains(@id, 'treatment_date')]", display_date
    @browser.select "//div[@class='treatment'][1]//select[contains(@id, 'treatment_given_yn_id')]", "label=Yes"

    @browser.type "//div[@class='treatment'][2]//input[contains(@id, 'treatment_attributes__treatment')]", "Whiskey" 
    @browser.type "//div[@class='treatment'][2]//input[contains(@id, 'treatment_date')]", display_date
    @browser.select "//div[@class='treatment'][2]//select[contains(@id, 'treatment_given_yn_id')]", "label=Yes"

    save_cmr(@browser).should be_true

    @browser.is_text_present('CMR was successfully created.').should be_true
    @browser.is_text_present("Leeches").should be_true
    @browser.is_text_present("Whiskey").should be_true
  end

  it "should allow removing a treatement" do
    edit_cmr(@browser)
    click_core_tab(@browser, "Clinical")
    @browser.click "remove_treatment_link"
    save_cmr(@browser).should be_true
    @browser.is_text_present("Leeches").should_not be_true
  end

  it "should allow editing a treatemt" do
    pending "No XPath way to narrow down to this element as ends-with does not seem to be supported in FF."
    edit_cmr(@browser)
    @browser.type "//div[@class='treatment'][1]//input[ends-with(@id, '_treatment')]", "Eye of newt" 
    click_core_tab(@browser, "Clinical")
    save_cmr(@browser).should be_true
    @browser.is_text_present('Eye of newt').should be_true
  end

end