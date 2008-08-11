require File.dirname(__FILE__) + '/../spec_helper'

describe MorbidityEvent do
  fixtures :events, :participations, :entities, :places, :people, :lab_results, :hospitals_participations, :codes

  event_hash = {
    "active_patient" => {
      "active_primary_entity" => {
        "entity_type"=>"person", 
        "person" => {
          "last_name"=>"Green"
        }
      }
    }
  }

  describe "handling new labs and lab results" do

    describe "receiving a new lab and lab result" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>"New Lab One Result", "test_type" => "Urinalysis", "interpretation" => "Healthy"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_lab_hash_1))
      end

      it "should create a new participation linked to the event" do
        lambda {@event.save}.should change {Participation.count}.by(2)
        @event.participations.find_by_role_id(codes(:participant_testing_lab).id).should_not be_nil
      end

      it "should add a new lab" do
        lambda {@event.save}.should change {Place.count}.by(1)
        @event.labs.first.secondary_entity.place_temp.name.should == "New Lab One"
      end

      it "should add a new lab result" do
        lambda {@event.save}.should change {LabResult.count}.by(1)
        @event.labs.first.lab_results.first.lab_result_text.should == "New Lab One Result"
        @event.labs.first.lab_results.first.test_type.should == "Urinalysis"
        @event.labs.first.lab_results.first.interpretation.should == "Healthy"
      end
    end

    describe "receiving an existing lab and a new lab result" do

      before(:each) do
        exisitng_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(exisitng_lab_hash_1))
      end

      it "should not create a new lab" do
        lambda {@event.save}.should_not change {Place.count}
      end

      it "should link to the existing lab" do
        @event.save
        @event.labs.first.secondary_entity.should eql(entities(:Existing_Lab_One))
      end

      it "should add a new lab result" do
        lambda {@event.save}.should change {LabResult.count}.by(1)
        @event.labs.first.lab_results.first.lab_result_text.should == "Existing Lab Result"
      end
    end

    describe "receiving a lab with no lab result" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>""}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_lab_hash_1))
      end

      it "should be invalid" do
        @event.should_not be_valid
        @event.labs.first.lab_results.first.should have(1).error_on(:lab_result_text)
      end

    end

    describe "receiving a lab result with no lab" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"", "lab_result_text"=>"Whatever"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_lab_hash_1))
      end

      it "should be invalid" do
        @event.should_not be_valid
      end
    end

    describe "receiving a lab result with no lab and no lab result information" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"", "lab_result_text"=>"", "test_type" => "", "interpretation" => ""}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_lab_hash_1))
      end


      it "should do nothing" do
        @event.should be_valid
        @event.labs.should be_empty
      end
    end

    describe "receiving two labs/lab results, one old one new" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>"New Lab One Result"},
              { "lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_lab_hash_1))
      end

      it "should create one new lab" do
        lambda {@event.save}.should change {Place.count}.by(1)
        @event.labs.first.secondary_entity.place_temp.name.should == "New Lab One"
      end
      
      it "should create two new lab results" do
        lambda {@event.save}.should change {LabResult.count}.by(2)
      end

      it "should create three participations (1 patient + 2 labs)" do
        lambda {@event.save}.should change {Participation.count}.by(3)
      end
    end

    describe "receiving two labs, both existing" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"},
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_lab_hash_1))
      end

      it "should not create any new labs" do
        lambda {@event.save}.should_not change {Place.count}
      end

      it "should create two new lab results" do
        lambda {@event.save}.should change {LabResult.count}.by(2)
      end
    end

    describe "receiving a new lab result for an existing event and participation" do
      before(:each) do
        existing_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"A new result"}
            ]
        }
        @new_lab_hash = event_hash.merge(existing_lab_hash_1)
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should not create any participations" do
        lambda {@event.update_attributes(@new_lab_hash)}.should_not change {Participation.count}
      end

      it "should create one new lab result" do
        lambda {@event.update_attributes(@new_lab_hash)}.should change {LabResult.count}.by(1)
      end
    end
  end

  describe "handling exisiting lab results" do

    describe "receiving an edited lab result" do

      before(:each) do
        @existing_lab_hash_1 = {
          "existing_lab_attributes" => { "#{lab_results(:lab_guys_lab_result).id}" => {"lab_result_text"=>"Negative"}}
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should update the existing lab_result" do
        lambda {@event.update_attributes(@existing_lab_hash_1)}.should_not change {LabResult.count}
        @event.labs.first.lab_results.first.lab_result_text.should == "Negative"
      end
    end

    describe "receiving no lab results" do

      before(:each) do
        @existing_lab_hash_1 = {
          "existing_lab_attributes" => {}
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should delete existing lab results and participation" do
        lambda {@event.update_attributes(@existing_lab_hash_1)}.should change {LabResult.count + Participation.count}.by(-2)
      end

    end

  end

  describe "handling new hospitals" do

    describe "receiving a hospital and hospitalization dates" do

      before(:each) do
        new_hospital_hash = {
          "new_hospital_attributes" => 
            [
              {"secondary_entity_id" => places(:AVH).id, "admission_date" => "2008-07-15", "discharge_date" => "2008-07-16", "medical_record_number" => "1234"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_hospital_hash))
      end

      it "should create a new participation linked to the event" do
        lambda {@event.save}.should change {Participation.count}.by(2)
        @event.participations.find_by_role_id(codes(:participant_hospitalized_at).id).should_not be_nil
      end

      it "should add hospitalization dates and medical record number to hospitals_participation table " do
        lambda {@event.save}.should change {HospitalsParticipation.count}.by(1)
        @event.hospitalized_health_facilities.first.hospitals_participation.admission_date.should == Date.parse("2008-07-15")
        @event.hospitalized_health_facilities.first.hospitals_participation.discharge_date.should == Date.parse("2008-07-16")
        @event.hospitalized_health_facilities.first.hospitals_participation.medical_record_number.should == "1234"
      end
    end

    describe "receiving a hospital with no hospitalization dates" do

      before(:each) do
        new_hospital_hash = {
          "new_hospital_attributes" => 
            [
              {"secondary_entity_id" => places(:AVH).id, "admission_date" => "", "discharge_date" => "", "medical_record_number" => ""}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_hospital_hash))
      end

      it "should be valid" do
        @event.should be_valid
      end

      it "should create a new participation linked to the event" do
        lambda {@event.save}.should change {Participation.count}.by(2)
        @event.participations.find_by_role_id(codes(:participant_hospitalized_at).id).should_not be_nil
      end

      it "should not add any rows to hospitals_participation table " do
        lambda {@event.save}.should_not change {HospitalsParticipation.count}
      end
    end

    describe "receiving a hospital and out of order hospitalization dates" do

      before(:each) do
        new_hospital_hash = {
          "new_hospital_attributes" => 
            [
              {"secondary_entity_id" => places(:AVH).id, "admission_date" => "2008-07-16", "discharge_date" => "2008-07-15", "medical_record_number" => ""}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_hospital_hash))
      end

      it "should be invalid" do
        @event.should_not be_valid
      end

    end

    describe "receiving hospitalization dates but no hospital" do

      before(:each) do
        new_hospital_hash = {
          "new_hospital_attributes" => 
            [
              {"secondary_entity_id" => "", "admission_date" => "2008-07-14", "discharge_date" => "2008-07-15", "medical_record_number" => "1234"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_hospital_hash))
      end

      it "should make the participation invalid" do
        @event.hospitalized_health_facilities.first.should_not be_valid
        @event.hospitalized_health_facilities.first.should have(1).error_on(:base)
      end

    end

    describe "receiving new, empty hospitalization data" do

      before(:each) do
        new_hospital_hash = {
          "new_hospital_attributes" =>
          [
            { "secondary_entity_id" => "", "admission_date" => "", "discharge_date" => "", "medical_record_number" => ""}
          ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_hospital_hash))
      end

      it "should do nothing" do
        @event.should be_valid
        @event.hospitalized_health_facilities.should be_empty
      end

    end

  end

  describe "receiving existing hospitalization data" do

    describe "receiving edited hospitalization data" do
      before(:each) do
        @existing_hospital_hash = {
          "existing_hospital_attributes" => { "#{participations(:marks_hospitalized_at).id}" => {"secondary_entity_id" => "#{entities(:BRVH).id}", "admission_date" => "2008-07-14", "discharge_date" => "2008-07-15", "medical_record_number" => "1234"} }
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should update the existing hospital" do
        lambda {@event.update_attributes(@existing_hospital_hash)}.should_not change {Participation.count + HospitalsParticipation.count}
        @event.hospitalized_health_facilities.first.secondary_entity.current_place.name.should == "Bear River Valley Hospital"
        @event.hospitalized_health_facilities.first.hospitals_participation.admission_date.should == Date.parse("2008-07-14")
        @event.hospitalized_health_facilities.first.hospitals_participation.discharge_date.should == Date.parse("2008-07-15")
        @event.hospitalized_health_facilities.first.hospitals_participation.medical_record_number.should == "1234"
      end
    end

    describe "receiving empty hospitalization data" do

      before(:each) do
        @existing_hospital_hash = {
          "existing_hospital_attributes" => {}
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should delete existing hospital participation and hospitalization dates" do
        lambda {@event.update_attributes(@existing_hospital_hash)}.should change {HospitalsParticipation.count + Participation.count}.by(-2)
      end

    end

  end

  describe "handling diagnosing facilities" do

    describe "receiving a new diagnosing facility" do

      before(:each) do
        new_diagnostic_hash = {
          "new_diagnostic_attributes" => 
            [
              {"secondary_entity_id" => places(:AVH).id}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_diagnostic_hash))
      end

      it "should create a new participation linked to the event" do
        lambda {@event.save}.should change {Participation.count}.by(2)
        @event.participations.find_by_role_id(codes(:participant_diagnosing_health_facility).id).should_not be_nil
      end

    end

    describe "receiving an edited diagnosing facility" do
      before(:each) do
        @existing_diagnostic_hash = {
          "existing_diagnostic_attributes" => { "#{participations(:marks_diagnosed_at).id}" => {"secondary_entity_id" => "#{entities(:BRVH).id}"} }
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should update the existing diagnosing facility" do
        lambda {@event.update_attributes(@existing_diagnostic_hash)}.should_not change {Participation.count}
        @event.diagnosing_health_facilities.first.secondary_entity.current_place.name.should == "Bear River Valley Hospital"
      end
    end

    describe "receiving empty diagnostic data" do

      before(:each) do
        @existing_diagnostic_hash = {
          "existing_diagnostic_attributes" => {}
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should delete existing diagnosing facility participation" do
        lambda {@event.update_attributes(@existing_diagnostic_hash)}.should change {Participation.count}.by(-1)
      end

    end

  end  

  describe "handling new contacts" do

    describe "receiving one new contact" do

      before(:each) do
        new_contact_hash = {
          "new_contact_attributes" => 
            [
              { "last_name"=>"Allen", "first_name"=>"Steve"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_contact_hash))
      end

      it "should create a new participation linked to the event" do
        lambda {@event.save}.should change {Participation.count}.by(2)
        @event.participations.find_by_role_id(codes(:participant_contact).id).should_not be_nil
      end

      it "should add a new contact" do
        lambda {@event.save}.should change {Person.count}.by(2)
        @event.contacts.first.secondary_entity.person_temp.last_name.should == "Allen"
        @event.contacts.first.secondary_entity.person_temp.first_name.should == "Steve"
      end
    end

    describe "receiving multiple new contacts" do

      before(:each) do
        new_contact_hash = {
          "new_contact_attributes" => 
            [
              { "last_name"=>"Allen", "first_name"=>"Steve"},
              { "last_name"=>"Burns", "first_name"=>"George"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_contact_hash))
      end

      it "should create a new participation linked to the event" do
        lambda {@event.save}.should change {Participation.count}.by(3)
        @event.participations.find_by_role_id(codes(:participant_contact).id).should_not be_nil
      end

      it "should add two new contacts" do
        lambda {@event.save}.should change {Person.count}.by(3)
      end
    end

    describe "receiving a contact with a first name but no last name" do

      before(:each) do
        new_contact_hash = {
          "new_contact_attributes" => 
            [
              { "last_name"=>"", "first_name"=>"Steve"}
            ]
        }
        @event = MorbidityEvent.new(event_hash.merge(new_contact_hash))
      end

      it "should be invalid" do
        @event.should_not be_valid
        @event.contacts.first.secondary_entity.person_temp.should have(1).error_on(:last_name)
      end
    end

    describe "Receiving an edited contact" do
      before(:each) do
        @existing_contact_hash = {
          "existing_contact_attributes" => { "#{entities(:Groucho).id}" => {"last_name" => "Marx", "first_name" => "Chico"} }
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should update the existing contact" do
        @event.contacts.first.secondary_entity.person_temp.first_name.should == "Groucho"
        lambda {@event.update_attributes(@existing_contact_hash)}.should_not change {Participation.count}
        @event.contacts.first.secondary_entity.person_temp.first_name.should == "Chico"
        @event.contacts.first.secondary_entity.person_temp.last_name.should == "Marx"
      end
    end
    
    describe "receiving empty contact data" do

      before(:each) do
       @existing_contact_hash = {
          "existing_contact_attributes" => {}
        }
        @event = MorbidityEvent.find(events(:marks_cmr).id)
      end

      it "should delete existing contact" do
        lambda {@event.update_attributes(@existing_contact_hash)}.should change {Participation.count}.by(-1)
      end

    end

  end

  describe "Routing an event" do

    before(:each) do
      @event = MorbidityEvent.find(events(:marks_cmr).id)
    end

    describe "with legitimate parameters" do
      it "should not raise an exception" do
        lambda { @event.route_to_jurisdiction(entities(:Davis_County)) }.should_not raise_error()
      end

      it "should change the jurisdiction and set status to 'assigned to LHD'" do
        @event.active_jurisdiction.secondary_entity.current_place.name.should == places(:Southeastern_District).name
        @event.event_status.should eql(external_codes(:event_status_new))
        @event.route_to_jurisdiction(entities(:Davis_County).id)
        @event.event_status_id.should eql(external_codes(:event_status_assigned_lhd).id)
        @event.active_jurisdiction.secondary_entity.current_place.name.should == places(:Davis_County).name
      end
    end

    describe "with bad parameters" do
      it "should raise an error if passed in a non-existant place" do
        lambda { @event.route_to_jurisdiction(99999) }.should raise_error()
      end

      it "should raise an error if passed in a place that is not a jurisdction" do
        lambda { @event.route_to_jurisdiction(entities(:AVH)) }.should raise_error()
      end
    end

  end

  describe "under investigation" do
    fixtures :external_codes

    it "should not be under investigation in the default state" do
      event = MorbidityEvent.new
      event.should_not be_under_investigation
    end

    it "should not be under investigation if it is new" do
      event = MorbidityEvent.new(:event_status => external_codes(:event_status_new))
      event.should_not be_under_investigation
    end


    it "should be under investigation if set to under investigation" do
      event = MorbidityEvent.new :event_status => external_codes(:event_status_under_investigation)
      event.should be_under_investigation
    end

    it "should be under investigation if reopened by manager" do
      event = MorbidityEvent.new :event_status => external_codes(:event_status_reopened_manager)
      event.should be_under_investigation
    end

    it "should be under investigation if investigation is complete" do
      event = MorbidityEvent.new :event_status => external_codes(:event_status_investigation_complete)
      event.should be_under_investigation
    end
  end

  describe "Saving an event" do
    it "should generate an event onset date set to today" do
      event = MorbidityEvent.new(event_hash)
      event.save.should be_true
      event.event_onset_date.should == Date.today
    end
  end

  describe "handling telephone numbers" do
    fixtures :external_codes, :entities_locations, :locations, :addresses
    
    describe "adding new telephone number" do
      def new_telephone_hash
        { :new_telephone_attributes =>  
          [ { :entity_location_type_id => ExternalCode.telephone_location_type_ids[0].to_s,
              :area_code => '123',
              :phone_number => '4567890' } ] }
      end

      def create_event(event_hash)
        h = new_telephone_hash 
        yield h if block_given?
        @event = MorbidityEvent.new(event_hash.merge(h))
      end

      it "should be able to add a new phone number " do           
        create_event(event_hash)
        lambda {@event.save}.should change {EntitiesLocation.count}.by(1)      
        el = @event.patient.primary_entity.telephone_entities_locations[0]
        el.entity_location_type.code_description == 'Unknown'
        @event.should be_valid
        el.current_phone.should_not be_nil
      end      

# TODO: Restore this test when telephone validation is fixed
#      it "should not save invalid phone numbers" do
#        create_event(event_hash) { |h| h[:new_telephone_attributes][0][:area_code] = '32' }
#        @event.should_not be_valid
#      end
      
      it "should allow adding multiple new phone numbers" do
        create_event(event_hash) do |h|
          h[:new_telephone_attributes] << { 
            :area_code => '330', 
            :phone_number => '322-1234', 
            :email_address => 'joe@bagadonuts.com', 
            :entity_location_type_id => ExternalCode.telephone_location_type_ids[1] }
          
        end
        lambda {@event.save}.should change {EntitiesLocation.count}.by(2)      
        el = @event.patient.primary_entity.telephone_entities_locations[1]
        @event.should be_valid
        el.entity_location_type.code_description == 'Home'
        el.area_code.should == '330'
        el.phone_number.should == '3221234'
        el.email_address.should == 'joe@bagadonuts.com'
        el.current_phone.simple_format.should == '(330) 322-1234'
      end

      it "should allow adding phone numbers when editing cmrs" do
        h = new_telephone_hash.merge(:existing_telephone_attributes => {})
        event = events(:marks_cmr)
        event.patient.should_not be_nil
        event.patient.primary_entity.should_not be_nil
        event.patient.primary_entity.entities_locations.size.should > 0
        event.update_attributes(h)
        event.should be_valid
      end

      it "should not add the phone number if no telephone attributes are specified" do
        create_event(event_hash) do |h|
          h[:new_telephone_attributes] = 
            [ { :entity_location_type_id => ExternalCode.telephone_location_type_ids[0].to_s } ]
        end
        lambda {@event.save}.should_not change {EntitiesLocation.count}.by(1)      
        @event.patient.primary_entity.telephone_entities_locations.should be_empty
        @event.should be_valid
      end

    end

  end
end