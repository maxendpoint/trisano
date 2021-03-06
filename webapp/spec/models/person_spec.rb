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

describe Person, "with last name only" do
  before(:each) do
    @person = Person.new(:last_name => 'Lacey')
  end

  it "should be valid" do
    @person.should be_valid
  end

  it "should save without errors" do
    @person.save.should be_true
    @person.errors.should be_empty
  end
  
  it "should not have a Soundex code for first name" do
    @person.save.should be_true
    @person.first_name_soundex.should be_nil
  end
  
end

describe Person, "without a last name" do
  before(:each) do
    @person = Person.new
  end

  it "should not be valid" do
    @person.should_not be_valid
  end

  it "should not be saveable" do
    @person.save.should be_false
    @person.should have(1).error_on(:last_name)
  end
end

describe Person, "with first and last names" do

  it "should have Soundex codes after save" do
    first_name = 'Robert'
    last_name = 'Ford'
    
    @person = Person.new(:last_name => last_name, :first_name => first_name)
    
    @person.save.should be_true
    @person.first_name_soundex.should eql(first_name.to_soundex)
    @person.last_name_soundex.should eql(last_name.to_soundex)
  end

  it "should still soundex names w/ non-alpha chars" do
    @person = Person.create(:last_name => "O'Conner", :first_name => 'Johnny-5')
    @person.first_name_soundex.should_not be_nil
    @person.last_name_soundex.should_not be_nil
  end

  it "should have full name 'Robert Ford'" do
    first_name = 'Robert'
    last_name = 'Ford'
    person = Person.new(:last_name => last_name, :first_name => first_name)
    person.full_name.should == 'Robert Ford'
  end

end

describe Person, "with associated codes" do
  fixtures :external_codes

  before(:each) do
    @ethnicity = ExternalCode.find_by_code_name('ethnicity')
    @gender = ExternalCode.find_by_code_name('gender')
    @person = Person.create(:last_name => 'Lacey', 
      :ethnicity => @ethnicity,
      :birth_gender => @gender)
  end

  it "should retrieve with the same codes" do
    person = Person.find(@person.id)
    person.ethnicity.should eql(@ethnicity)
    person.birth_gender.should eql(@gender)
  end
end

describe Person, "with dates of birth and/or death" do
  it "should allow only valid dates" do
    person = Person.new(:last_name => 'Lacey', :birth_date => "2007-02-29", :date_of_death => "today")
    person.should_not be_valid
    person.should have(1).error_on(:birth_date)
    person.should have(1).error_on(:date_of_death)

    person = Person.new(:last_name => 'Lacey', :birth_date => "2008-02-29", :date_of_death => "02/28/2009")
    person.should be_valid
  end

  it "should not be valid to die before being born" do
    person = Person.new(:last_name => 'Lacey', :birth_date => "2008-12-31", :date_of_death => "2008-12-30")
    person.should_not be_valid
  end

  it "should be valid to die after being born" do
    person = Person.new(:last_name => 'Lacey', :birth_date => "2007-12-31", :date_of_death => "2008-12-30")
    person.should be_valid
  end

  it "should calculate an age if birth_date is not blank" do
    person = Person.new(:last_name => 'Entwistle', :birth_date => 10.years.ago)
    person.age.should == 10
  end
  

  it "should not calculate an age if the birth_date is blank" do
    person = Person.new(:last_name => 'Entwistle')
    person.age.should be_nil
  end
    
end

describe Person, "loaded from fixtures" do
  fixtures :people, :external_codes

  it "should have a non-empty collection of people" do
    Person.find(:all).should_not be_empty
  end

  it "should find an existing person" do
    person = Person.find(people(:groucho_marx).id)
    person.should eql(people(:groucho_marx))
  end

  it "should have an ethnicity of other" do
    people(:groucho_marx).ethnicity.should eql(external_codes(:ethnicity_other))
  end

  it "should have a birth_gender of male" do
    people(:groucho_marx).birth_gender.should eql(external_codes(:gender_male))
  end

  it "should have a primary language of Spanish" do
    people(:groucho_marx).primary_language.should eql(external_codes(:language_spanish))
  end

  it "should look up the birth gender description" do
    people(:groucho_marx).birth_gender_description.should eql('Male')
  end
    
  it "should look up the ethnicity description" do
    people(:groucho_marx).ethnicity_description.should eql('Other')
  end

  it "should look up the primary language description" do
    people(:groucho_marx).primary_language_description.should eql('Spanish')
  end
end

describe Person, "with one or more races" do
  fixtures :external_codes  

  it "should look up the race description" do
    entity = mock(PersonEntity)
    entity.stub!(:races).and_return([external_codes(:race_white)])
    person = Person.new(:last_name => 'Entwistle')
    person.stub!(:person_entity).and_return(entity)
    person.race_description.should eql('White')
  end

  it "should build a race description if several races" do
    entity = mock(PersonEntity)
    entity.stub!(:races).and_return([external_codes(:race_white), external_codes(:race_asian), external_codes(:race_indian)])
    person = Person.new(:last_name => 'Entwistle')
    person.stub!(:person_entity).and_return(entity)
    person.race_description.should eql('White, Asian and American Indian')
  end

  it "should not be an error to have no race" do
    entity = mock(PersonEntity)
    entity.stub!(:races).and_return([])    
    person = Person.new(:last_name => 'Entwistle')
    person.stub!(:person_entity).and_return(entity)
    person.race_description.should be_nil
  end

end

describe Person, 'find by ts' do
  before(:all) do
    # a little hack because PG adapters don't consistently escape single quotes      
    begin
      PostgresPR
      @oreilly_string = "o\\\\'reilly"
    rescue
      @oreilly_string = "o''reilly"
    end
  end

  before(:each) do
    @conn = ActiveRecord::Base.connection
    Person.reset_last_query
  end
    
  it 'should include soundex codes for fulltext search' do
    Person.find_by_ts(:fulltext_terms => "davis o'reilly", :jurisdiction_id => 1)
    Person.last_query.should_not be_nil
    Person.last_query.should =~ /'davis \| #@oreilly_string \| #{'davis'.to_soundex.downcase} \| #{"o'reilly".to_soundex.downcase}'/
  end

end

describe Person, 'find_all_for_filtered_view' do

  describe "when excluding deleted people" do
    it 'should not include deleted people by default, only when including the :show_deleted option' do
      last_name = "Deleted-Spec-Guy"

      @person_entity_1 = Factory.create(:person_entity, :person => Factory.create(:person, :last_name => last_name ))
      @person_entity_2 = Factory.create(:person_entity, :person => Factory.create(:person, :last_name => last_name ))
      @deleted_person_entity = Factory.create(:person_entity, :person => Factory.create(:person, :last_name => last_name ), :deleted_at => Time.now)
      
      Person.find_all_for_filtered_view(:last_name => last_name).size.should == 2
      Person.find_all_for_filtered_view(:last_name => last_name).detect { |person| person.person_entity.id == @deleted_person_entity.id }.should be_nil
      Person.find_all_for_filtered_view(:last_name => last_name, :show_deleted => true).size.should == 3
      Person.find_all_for_filtered_view(:last_name => last_name, :show_deleted => true).detect { |person| person.person_entity.id == @deleted_person_entity.id }.should_not be_nil
    end
  end

end

describe Person, 'named scopes for clinicians' do

  before(:each) do
    @clinician = Factory.create(:person_entity, :person => Factory.create(:clinician))
    @clinician_2 = Factory.create(:person_entity, :person => Factory.create(:clinician))
    @deleted_clinician = Factory.create(:person_entity, :person => Factory.create(:clinician), :deleted_at => Time.now)
    @non_clinician = Factory.create(:person_entity, :person => Factory.create(:person))
  end

  it "should return all clinicians" do
    Person.clinicians.size.should == 3
    Person.clinicians.detect { |clinician| clinician.person_entity.id == @deleted_clinician.id }.should_not be_nil
    Person.clinicians.detect { |clinician| clinician.person_entity.id == @non_clinician.id }.should be_nil
  end
  
  it "should return all active clinicians" do
    Person.active_clinicians.size.should == 2
    Person.active_clinicians.detect { |clinician| clinician.person_entity.id == @deleted_clinician.id }.should be_nil
    Person.active_clinicians.detect { |clinician| clinician.person_entity.id == @non_clinician.id }.should be_nil
  end

end
