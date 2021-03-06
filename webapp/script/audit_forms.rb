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

p "Retriveing all forms"
forms = Form.find(:all, :order => "name, version")

forms.each do |form|
  message = "#{form.name} "
  if form.is_template
    message << "master copy "
  else
    message << "version #{form.version} "
  end

  if form.structure_valid?
    message << "is OK"
    p message
  else
    message << "is invalid"
    p message
    p "================================================"
    form.errors.each do |key, value|
      p "#{key}: #{value}"
    end
    p "================================================"
  end
end