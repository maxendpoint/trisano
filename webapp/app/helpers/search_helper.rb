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

require 'csv'

module SearchHelper

  # Debt: This is here because it's a special case of finding a record
  # for search csv and it makes mocking the view logic easier. Also, I
  # toyed with the idea of adding a method to the event model, but the
  # possibility of an event.event call was just too awful.
  def find_event(record)
    Event.find(record.event_id)
  end

  # Not very Ruby, but...
  def array_of_strs_to_ints(str_array)
    str_array.collect { |str| str.to_i } unless str_array.nil?
  end

end
