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

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'export/cdc' do
  fixtures :events, :participations, :disease_events, :diseases, :export_conversion_values, :export_columns, :diseases_export_columns

  describe 'writing the result' do
    include Export::Cdc::CdcWriter

    before :each do
      @result = ' ' * 10 + 'Beaver'
    end

    it 'should not shorten string when inserting values shorter then :length' do
      write('Utah', :starting => 0, :length => 10, :result => @result)
      @result.should == 'Utah      Beaver'
    end
  end

  describe 'converting values for core fields' do
    include Export::Cdc::CdcWriter

    before :each do      
      @conversion = mock(ExportConversionValue)
    end
    
    it 'should grab the right side of numbers (to get two digit years)' do      
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 2
      @conversion.should_receive(:value_to).once.and_return('error')
      convert_value('2009', @conversion).should == '09'
    end

    it 'should ljust string values' do
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 4
      @conversion.should_receive(:value_to).once.and_return('error')
      convert_value('Homer', @conversion).should == 'Home'
    end

    it 'should strip whitespace values' do
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 8
      @conversion.should_receive(:value_to).once.and_return('error')
      convert_value('Homer', @conversion).should == 'Homer'
    end

    it 'should not rjust long postal codes' do
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 5
      @conversion.should_receive(:value_to).once.and_return('error')
      convert_value('46062-5888', @conversion).should == '46062'
    end

    # strftime rules

    it 'should convert dates to mm/dd/yy if value_to is %m/%d/%y' do
      @conversion.should_receive(:conversion_type).once.and_return 'date'
      @conversion.should_receive(:value_to).once.and_return('%m/%d/%y')
      value = ''
      lambda{value = convert_value('January 12th, 2009', @conversion)}.should_not raise_error
      value.should == '01/12/09'
    end

    it 'should convert dates to YYYYMMDD if value_to is %Y%m%d' do
      @conversion.should_receive(:conversion_type).once.and_return 'date'
      @conversion.should_receive(:value_to).once.and_return('%Y%m%d')
      value = ''
      lambda{value = convert_value('January 12th, 2009', @conversion)}.should_not raise_error
      value.should == '20090112'
    end

    it 'should replace blank dates with field width 9s' do
      @conversion.should_receive(:conversion_type).once.and_return 'date'
      @conversion.should_receive(:value_to).once.and_return('%Y%m%d')
      @conversion.should_receive(:length_to_output).once.and_return(8)
      value = ''
      lambda{value = convert_value('', @conversion)}.should_not raise_error
      value.should == '99999999'
    end

    it 'should replace invalid dates with field width 9s' do
      @conversion.should_receive(:conversion_type).once.and_return 'date'
      @conversion.should_receive(:value_to).once.and_return('%Y%m%d')
      @conversion.should_receive(:length_to_output).once.and_return(8)
      value = ''
      lambda{value = convert_value('not_a_date', @conversion)}.should_not raise_error
      value.should == '99999999'
    end

    it 'should replace nil dates with field width 9s' do
      @conversion.should_receive(:conversion_type).once.and_return 'date'
      @conversion.should_receive(:length_to_output).once.and_return(8)
      @conversion.should_receive(:value_to).once.and_return('%Y%m%d')
      value = ''
      lambda{value = convert_value(nil, @conversion)}.should_not raise_error
      value.should == '99999999'
    end
  end

  describe 'core path method calling' do    

    it 'should not blow up on broken configs' do
      mock_config = mock(FormElement)
      mock_config.should_receive(:call_chain).once.and_return([:not_a_method])
      value = ''
      lambda{value = MorbidityEvent.new.value_converted_using(mock_config)}.should_not raise_error
      value.should be_nil
    end
      
  end
end
