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

class PlaceEventsController < EventsController
  def index
    render :text => "Place exposures cannot be accessed directly.", :status => 405
  end

  def show
    # @event initialized in can_view? filter

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def new
    render :text => "Place exposures cannot be created directly.", :status => 405
  end

  def edit
    # Filter #can_update? is called which loads up @event with the found event. Nothing to do here.
  end

  def create
    render :text => "Place exposures cannot be created directly.", :status => 405
  end

  def update
    go_back = params.delete(:return)
    @event.add_note("Edited event") unless go_back

    respond_to do |format|
      if @event.update_attributes(params[:place_event])
        flash[:notice] = 'Place event was successfully updated.'
        format.html {
          if go_back
            render :action => "edit"
          else
            query_str = @tab_index ? "?tab_index=#{@tab_index}" : ""
            redirect_to(place_event_url(@event) + query_str)
          end
        }
        format.xml  { head :ok }
        format.js   { render :inline => "Exposure event saved.", :status => :created }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => "Exposure Event not saved: <%= @event.errors.full_messages %>", :status => :unprocessable_entity }
      end
    end
  end

end
