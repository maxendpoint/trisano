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

#
# Form-builder steps that can be utilized by standard or enhanced UATs
#

# Generic form-creation steps that vary in what you can provide if randomly
# generated names and diseases will do.

Given(/^a (.+) event form exists$/) do |event_type|
  unique_form_name = get_unique_name(3)
  @form = create_form(event_type, unique_form_name, unique_form_name, get_random_disease)
end

Given(/^a (.+) event form exists for the disease (.+)$/) do |event_type, disease|
  unique_form_name = get_unique_name(3)
  @form = create_form(event_type, unique_form_name, unique_form_name, disease)
end

Given(/^a (.+) event form exists for the disease (.+) with the name (.+) \((.+)\)$/) do |event_type, disease, form_name, form_short_name|
  @form = create_form(event_type, form_name, form_short_name, disease)
end

Given(/^that form is published$/) do
  @published_form = @form.publish
  @published_form.should_not be_nil
end

#
# Published form helpers.
#
# Note: Any questions added after will not be published unless another step publishes the form again
#

Given(/^a published form exists with the name (.+) \((.+)\) for a (.+) with the disease (.+)$/) do |form_name, form_short_name, event_type, disease|
  @form = create_form(event_type, form_name, form_short_name, disease)
  @published_form = @form.publish
  @form
end

Given(/^a published form exists with the name (.+) \((.+)\) for a (.+) with any disease$/) do |form_name, form_short_name, event_type|
  @form = create_form(event_type, form_name, form_short_name, get_random_disease)
  @published_form = @form.publish
  @form
end

#
# Question helpers
#

Given(/^that form has (.+) questions$/) do |number_of_questions|
  number_of_questions.to_i.times do |question|
    question_element = QuestionElement.new({
        :parent_element_id => @form.investigator_view_elements_container.children[0].id,
        :question_attributes => {
          :question_text =>  "#{get_unique_name(3)} #{question}",
          :data_type => "single_line_text",
          :short_name => get_unique_name(2)
        }
      })
    question_element.save_and_add_to_form
  end
end

Given(/^that form has one question on the default view$/) do
  @question_element = QuestionElement.new({
      :parent_element_id => @form.investigator_view_elements_container.children[0].id,
      :question_attributes => {
        :question_text =>  get_unique_name(3),
        :data_type => "single_line_text",
        :short_name => get_unique_name(2)
      }
    })
  @question_element.save_and_add_to_form
end

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


#
# Core config helpers
#

Given /^that form has core follow ups configured for all core fields$/ do
  @default_view = @form.investigator_view_elements_container.children[0]

  # Create a core follow up for every core field that can be followed up on
  CoreField.find_all_by_event_type("morbidity_event").each do |core_field|
    if core_field.can_follow_up
      follow_up_element = FollowUpElement.new
      follow_up_element.form_id = @form.id
      follow_up_element.core_path = core_field.key

      # If the core field has a code name, then its potential answers are one of that code_name's codes
      if core_field.code_name
        # Get the code and do the magic incantation to make the follow up be considered a 'Code condition'
        code = core_field.code_name.codes.empty? ? core_field.code_name.external_codes.all(:order => "code_description ASC").first : core_field.code_name.codes.all(:order => "code_description ASC").first
        follow_up_element.condition = code.id
        follow_up_element.condition_id = code.id
      else

        # Setting all conditions to YES if they aren't code conditions. This will probably have to get
        # smarter as validations are added to fields (like postal code, for example, as you may not be able
        # to set postal code to YES is the future.) Smarts could be added by making the core_field table's
        # field_type a bit more specific. Currently there is just 'single_line_text' for text input form
        # fields, but types like 'numeric' and 'postal_code' could be added.
        #
        # Update: Fields are incrementally getting smarter. Age fields are now type numeric. The rest of
        # the text inputs are still single_line_text
        if core_field.field_type == "single_line_text"
          follow_up_element.condition = "YES"
        elsif core_field.field_type == "numeric"
          follow_up_element.condition = "1"
        end
        
      end
    
      follow_up_element.parent_element_id = @default_view.id
      follow_up_element.save_and_add_to_form

      # Add question to follow up container
      question_element = QuestionElement.new({
          :parent_element_id => follow_up_element.id,
          :question_attributes => {
            :question_text => "#{core_field.name} follow up?",
            :data_type => "single_line_text",
            :short_name => Digest::MD5::hexdigest(core_field.name)
          }
        })
      question_element.save_and_add_to_form
    end
  end
end
