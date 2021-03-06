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

describe LoincCode do
  fixtures :external_codes, :loinc_codes

  before do
    @scale = external_codes :loinc_scale_ord
  end

  it "should produce an error is a loinc code not in expected format" do
    LoincCode.create(:loinc_code => 'xxx-1').errors.on(:loinc_code).should == "is invalid (should be nnnnn-n)"
  end

  it 'loinc_code value should be present' do
    LoincCode.create(:loinc_code => '').errors.on(:loinc_code).should == "can't be blank"
  end

  it 'scale_id should be present' do
    LoincCode.create(:scale_id => '').errors.on(:scale_id).should == "can't be blank"
  end

  it 'by default, should return all lists in loinc code numerical order' do
    loinc = LoincCode.create! :loinc_code => '11234-1', :scale_id => @scale.id
    loinc.clone.update_attributes! :loinc_code => '114-9'
    LoincCode.find(:all).collect(&:loinc_code).should == ["114-9", "5221-7", "10000-1", "11234-1", "13954-3"]
  end

  describe 'loinc code' do

    it 'should be unique' do
      LoincCode.create :loinc_code => '999999-9', :scale_id => @scale.id
      LoincCode.create(:loinc_code => '999999-9').errors.on(:loinc_code).should == "has already been taken"
      LoincCode.create(:loinc_code => '888888-8').errors.on(:loinc_code).should be_nil
    end

    it 'should not be longer then 10 chars' do
      LoincCode.create(:loinc_code => '999999999-9').errors.on(:loinc_code).should == "is too long (maximum is 10 characters)"
      LoincCode.create(:loinc_code => '99999999-9' ).errors.on(:loinc_code).should be_nil
    end

    it 'should be left and right trimmed' do
      loinc = LoincCode.create(:loinc_code => '99999-9 ')
      loinc.errors.on(:loinc_code).should be_nil
      loinc.loinc_code.should == '99999-9'
    end

  end

  describe 'test name' do

    it 'should not be longer then 255 chars' do
      LoincCode.create(:loinc_code => '999999-9', :test_name => ('c' * 256)).errors.on(:test_name).should == "is too long (maximum is 255 characters)"
      LoincCode.create(:loinc_code => '999999-9', :test_name => ('c' * 255)).errors.on(:test_name).should be_nil
    end

  end

  describe '#search_unrelated_loincs' do

    before do
      @loinc_code = LoincCode.create!(:loinc_code => '14375-1',
                                      :test_name => 'Nulla felis nibh, aliquet eget, Unspecified',
                                      :scale_id => external_codes(:loinc_scale_ord).id)
      @common_test_type = CommonTestType.create! :common_name => 'Nulla felis nibh, aliquet eget.'
    end

    it 'should find all matches, if none are associated with this instance' do
      LoincCode.search_unrelated_loincs(@common_test_type, :test_name => 'nulla').should == [@loinc_code]
    end

    it 'should return empty array if all matches are already assoc, with this instance' do
      @common_test_type.update_loinc_code_ids :add => [@loinc_code.id]
      LoincCode.search_unrelated_loincs(@common_test_type, :test_name => 'nulla').should == []
    end

    it 'should return empty array if no search criteria provided' do
      LoincCode.search_unrelated_loincs(@common_test_type).should == []
    end

  end

  describe 'associations' do

    it { should belong_to(:common_test_type) }
    it { should have_many(:disease_common_test_types) }
    it { should have_many(:diseases) }
    it { should have_many(:loinc_codes_organisms) }
    it { should have_many(:organisms) }

  end

  describe "loading from text files" do
    fixtures :external_codes

    it 'should bulk load from csv' do
      lambda do
        LoincCode.load_from_csv <<CSV
10349-9,Total Ab,Brucella Ab Ser-aCnc,Qn
10352-3,Culture,Bacteria Genital Aerobe Cult,Nom
10674-0,Surface Ag (HBsAg),HBV surface Ag Tiss Ql ImStn,Ord
108-1,Cefotaxime susceptibility,Cefotaxime Islt MIC,OrdQn
CSV
      end.should change(LoincCode, :count).by(4)
    end

    it 'csv bulk loads associate loincs w/ a common test type' do
      CommonTestType.create :common_name => 'Total Ab'
      LoincCode.load_from_csv '10349-9,Total Ab,Brucella Ab Ser-aCnc,Qn'
      LoincCode.find_by_loinc_code('10349-9').common_test_type.should_not be_nil
    end
  end
end
