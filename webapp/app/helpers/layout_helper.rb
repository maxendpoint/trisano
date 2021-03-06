
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

module LayoutHelper

  def render_geocode_js_includes
    # PLUGIN_HOOK - render_geocode_js_includes()
  end

  def render_onload_event
    # PLUGIN_HOOK - render_onload_event()
    
    return %{ shortcuts_init('#{home_path}');
              focus_init(); }
  end

  def render_help_link
    # PLUGIN_HOOK - render_help_link()
  end

  def render_system_message
    # PLUGIN_HOOK - render_system_message()
  end

  def render_footer
    # PLUGIN_HOOK - render_footer()
    
    result = ""

    result << "<div class='footlogo'>"
    result << image_tag("foot.png", :border => 0)
    result << "</div>"
    result << "<div class='foottext'>"
    result << "<div class='top'>"
    result << "<a href='https://wiki.csinitiative.com/display/tri/TriSano+-+2.0+FINAL+Release+Notes'>TriSano™ 2.0 FINAL</a>"
    result << "</div>"
    result << "<div class='bottom'>"
    result << "<a href='http://www.trisano.org/collaborate/'>Collaborate</a>"
    result << "&nbsp;|&nbsp;"
    result << "User Feedback (<a href='http://groups.google.com/group/trisano-user'>web</a>, <a href='mailto:trisano-user@googlegroups.com'>email</a>)"
    result << "&nbsp;|&nbsp;"
    result << "<a href='http://www.trisano.org'>About</a>"
    result << "&nbsp;|&nbsp;"
    result << "<a href='http://www.trisano.org/collaborate/licenses/'>License</a>"
    result << "&nbsp;|&nbsp;"
    result << "<a href='http://github.com/csinitiative/trisano/tree/master'>Source</a>"
    result << "</div>"
    result << "<div class='bottom'>"
    result << "Copyright © 2009 Collaborative Software Foundation"
    result << "</div>"

    result
  end
  
end
