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

module ExportHelper

  # Significant Debt: Hard coding all of this for now.  This has to change.

  def get_ibis_health_district(jurisdiction)
    case jurisdiction.short_name
    when "Bear River" then 1
    when "Central Utah" then 2
    when "Davis County" then 3
    when "Salt Lake Valley" then 4
    when "Southeastern Utah" then 5
    when "Southwest Utah" then 6
    when "Summit County" then 7
    when "Tooele County" then 8
    when "TriCounty" then 9
    when "Utah County" then 10
    when "Wasatch County" then 11
    when "Weber-Morgan" then 12
    when "Utah State" then 99
    when "Out of State" then 99
    when "Unassigned" then 99
    when nil then 99
    end
  end

  def get_ibis_ethnicity(ethnicity)
    return "." unless ethnicity
    case ethnicity.code_description
    when "Hispanic or Latino" then 1
    when "Not Hispanic or Latino", "Other" then 2
    when "Unknown" then 9
    else "."
    end
  end

  def get_ibis_status(status)
    case status.the_code
    when "C" then 1 
    when "P" then 2 
    when "S" then 3 
    end
  end

  def get_ibis_sex(sex)
    return "." unless sex
    case sex.the_code
    when "M" then 1
    when "F" then 2
    when "U" then 9
    else "."
    end
  end
end