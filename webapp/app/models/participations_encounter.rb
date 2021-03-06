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

class ParticipationsEncounter < ActiveRecord::Base
  has_one :encounter_event
  
  # Investigator. Consider some sugar here.
  belongs_to :user

  class << self
    def location_type_array
      [["Clinic", "clinic"], ["Home", "home"], ["Phone", "phone"], ["School", "school"], ["Work", "work"], ["Other", "other"]]
    end

    def valid_location_types
      @valid_location_types ||= location_type_array.map { |location_type| location_type.last }
    end
  end

  validates_presence_of :encounter_date, :user, :encounter_location_type
  validates_date :encounter_date
  validates_inclusion_of :encounter_location_type, :in => self.valid_location_types, :message => "is not valid"

end
