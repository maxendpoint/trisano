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

class CreateLoincCodes < ActiveRecord::Migration
  def self.up
    create_table :loinc_codes do |t|
      t.string   :loinc_code, :limit => 10, :null => false
      t.string   :test_name
      t.integer  :common_test_type_id

      t.timestamps
    end

    add_index    :loinc_codes, :loinc_code, :unique => true
  end

  def self.down
    remove_index :loinc_codes, :loinc_code
    drop_table   :loinc_codes
  end
end
