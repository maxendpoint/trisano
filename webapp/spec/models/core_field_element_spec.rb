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

require File.dirname(__FILE__) + '/../spec_helper'

describe CoreFieldElement do
 
  before(:each) do
    @form = Form.new(:name => 'Test form', :event_type => 'morbidity_event', :short_name => 'cfespec')
    @form.save_and_initialize_form_elements
    @core_field_element = CoreFieldElement.new
    MorbidityEvent.stub!(:exposed_attributes).and_return({ 'key_1' => {:name => 'field_1', :fb_accessible => true}, 
                                                           'key_2' => {:name => 'field_2', :fb_accessible => true}, 
                                                           'key_3' => {:name => 'field_3', :fb_accessible => true},
                                                           'key_4' => {:name => 'field_4', :fb_accessible => false}})

    @core_field_element.core_path = MorbidityEvent.exposed_attributes.keys[0]
  end

  it "should be valid" do
    @core_field_element.name = "name"
    @core_field_element.should be_valid
  end

  describe "when determining available core fields" do
    it "should return nil if no parent_element_id is set on the core field element" do
      @core_field_element.available_core_fields.should be_nil
    end
    
    it "should return all core field names when none are in use" do
      @core_field_element.parent_element_id = @form.form_base_element.id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.size.should == 3
      available_core_fields.flatten.include?(MorbidityEvent.exposed_attributes.keys[0]).should be_true
    end
    
    it "should return only available core view names when some are in use" do
      base_element_id = @form.form_base_element.id
     
      patient_last_name_field_config = CoreFieldElement.new(
        :parent_element_id => @form.core_field_elements_container.id, 
        :core_path => MorbidityEvent.exposed_attributes.keys[0]
      )
      patient_last_name_field_config.save_and_add_to_form.should_not be_nil
       
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.size.should ==  2
      available_core_fields.flatten.include?(MorbidityEvent.exposed_attributes.keys[0]).should be_false
    end

    it "should not return any fields that are not accessible to form builder" do
      @core_field_element.parent_element_id = @form.form_base_element.id
      available_core_fields = @core_field_element.available_core_fields
      available_core_fields.detect { |field| field[1] == 'key_4' }.should be_nil
    end

  end
  
  describe "when created with 'save and add to form'" do
    it "should be a child of the form's base" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.parent_id.should_not be_nil
      @form.core_field_elements_container.children[0].id.should == @core_field_element.id
    end
    
    it "should have a name" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.reload
      @core_field_element.name.should eql(MorbidityEvent.exposed_attributes[MorbidityEvent.exposed_attributes.keys[0]][:name])
    end
    
    it "should override any name provided with the one in the exposed attributes" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.name = "name assigned"
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.reload
      @core_field_element.name.should eql(MorbidityEvent.exposed_attributes[MorbidityEvent.exposed_attributes.keys[0]][:name])
    end
    
    it "should receive a tree id" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.tree_id.should_not be_nil
      @core_field_element.tree_id.should eql(@form.form_base_element.tree_id)
    end
    
    it "should bootstrap the before and after core field elements" do
      @core_field_element.parent_element_id = @form.core_field_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.children.size.should eql(2)
      @core_field_element.children[0].is_a?(BeforeCoreFieldElement).should be_true
      @core_field_element.children[1].is_a?(AfterCoreFieldElement).should be_true
    end
    
    it "should fail if form validation fails" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      invalidate_form(@form)
      @core_field_element.save_and_add_to_form.should be_nil
      @core_field_element.errors.should_not be_empty
    end
  end
  
  describe "when updated" do
    it "should succeed if form validation passes" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.update_and_validate(:name => "Updated Name").should_not be_nil
      @core_field_element.name.should eql("Updated Name")
      @core_field_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      @core_field_element.update_and_validate(:name => "Updated Name").should be_nil
      @core_field_element.errors.should_not be_empty
    end
  end
  
  describe "when deleted" do
    it "should succeed if form validation passes" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      @core_field_element.destroy_and_validate.should_not be_nil
      @core_field_element.errors.should be_empty
    end

    it "should fail if form validation fails" do
      @core_field_element.parent_element_id = @form.investigator_view_elements_container.id
      @core_field_element.save_and_add_to_form.should_not be_nil
      invalidate_form(@form)
      @core_field_element.destroy_and_validate.should be_nil
      @core_field_element.errors.should_not be_empty
    end
  end
  
end
