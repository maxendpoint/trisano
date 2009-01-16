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

require File.dirname(__FILE__) + '/../spec_helper'

describe Answer do
  
  before(:each) do 
    question = Question.new :short_name => 'short_name_01'
    @answer = Answer.new :question => question
    @answer.text_answer = 's' * 2000    
  end
  
  it "should return the short name from the question" do
    @answer.short_name.should == 'short_name_01'
  end
  
  it 'should strip out the extra blank values from a radio button submission' do
    @answer.radio_button_answer=(["Yes", ""])
    @answer.text_answer.should eql("Yes")
  end
  
  it 'should produce an error if the answer text is too long' do
    @answer.text_answer = 's' * 2001
    @answer.should_not be_valid
    @answer.errors.size.should == 1
    @answer.errors.on(:text_answer).should_not be_nil
  end

end
