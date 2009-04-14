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

Given(/^that form has a question with the short name \"(.+)\"$/) do |short_name|
  @question_element = QuestionElement.new({
      :parent_element_id => @form.investigator_view_elements_container.children[0].id,
      :question_attributes => {
        :question_text => "I have a short name?",
        :data_type => "single_line_text",
        :short_name => short_name
      }
    })
  @question_element.save_and_add_to_form
end

When(/^I try to add a question to the default section without providing a short name$/) do
  add_question_to_view(@browser, "Default View", {
      :question_text => "Question without short name?",
      :data_type => "Single line text"
    }, true)
end

When(/^I try to add a question to the default section providing a short name$/) do
  add_question_to_view(@browser, "Default View", {
      :question_text => "Question without short name?",
      :short_name => "i_am_a_short_name",
      :data_type => "Single line text"
    })
end

When(/^I try to add a question to the default section providing a short name that is already in use$/) do
  add_question_to_view(@browser, "Default View", {
      :question_text => "Question without short name?",
      :short_name => "i_am_a_short_name",
      :data_type => "Single line text"
    }, true)
end

When(/^I edit that question to change its short name to "(.+)"$/) do |short_name|
  @short_name = short_name
  edit_question_by_id(@browser, @question_element.id, { :short_name => short_name })
end

When(/^I try to edit the question$/) do
  @browser.click("edit-question-#{@question_element.id}")
  wait_for_element_present("edit-question-form", @browser)
end

Then(/^the new question short name should be displayed on the screen$/) do
  @browser.is_text_present(@short_name).should be_true
end

Then(/^the short name should be read-only$/) do
  @browser.is_text_present(@short_name).should be_true
  @browser.is_element_present("//input[contains(@id, 'question_element_question_attributes_question_text')]").should be_true
  @browser.is_element_present("//input[contains(@id, 'question_element_question_attributes_short_name')]").should be_false
end




