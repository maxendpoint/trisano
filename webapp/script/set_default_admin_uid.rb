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

config = YAML::load_file "../distro/config.yml"
@default_admin_uid = config['default_admin_uid']

puts "Setting default administrator UID to #{@default_admin_uid}"

RoleMembership.transaction do
  unassigned_jurisdiction = Place.jurisdiction_by_name('Unassigned')
  admin_role = Role.find_by_role_name("Administrator")
  user = User.find_or_create_by_uid(@default_admin_uid)
  user.user_name = @default_admin_uid
  user.update_attributes(:role_membership_attributes => [{ :role_id => admin_role.id, :jurisdiction_id => unassigned_jurisdiction.id }])
  user.save!
end
