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

class MorbidityEventsController < EventsController
  include EventsHelper

  before_filter :capture_old_attributes, :only => [:update]

  def index
    return unless index_processing

    respond_to do |format|
      format.html # { render :template => "events/index" }
      format.xml  { render :xml => @events }
      format.csv
    end
  end

  def show
    @export_options = params[:export_options]
    
    # @event initialized in can_view? filter

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
      format.csv
      format.print { @print_options = params[:print_options] || [] }
    end
  end

  def new
    @event = MorbidityEvent.new
    
    prepopulate unless params[:from_search].nil?

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  def edit
    # Via filters above #can_update? is called which loads up @event with the found event.
    # Nothing to do here.
  end

  def create
    go_back = params.delete(:return)
    
    @event = MorbidityEvent.new
    if params[:from_event]
      org_event = Event.find(params[:from_event])
      components = params[:event_components]
      org_event.copy_event(@event, components || []) # Copy instead of clone to make sure contacts become morbs

      # A little DEBT:  Better to add a column to events that points at the 'parent,' and generate this reference in the view
      @event.add_note("Event derived from " + ActionView::Base.new.link_to("Event #{org_event.record_number}", cmr_path(org_event) )) if components && !components.empty?
    elsif params[:from_person]
      person = PersonEntity.find(params[:from_person])
      @event.copy_from_person(person)
    else
      @event.attributes = params[:morbidity_event]

      # Allow for test scripts and developers to jump directly to the "under investigation" state
      if RAILS_ENV == 'production'
        @event.primary_jurisdiction.name == "Unassigned" ? @event.workflow_state = "new" : @event.workflow_state = "accepted_by_lhd"
      end
      @event.event_onset_date = Date.today
    end

    unless User.current_user.is_entitled_to_in?(:create_event, @event.jurisdiction.place_entity.id)
      render :partial => "events/permission_denied", :locals => { :reason => "You do not have create priveleges in this jurisdiction", :event => @event }, :layout => true, :status => 403 and return
    end
    
    respond_to do |format|
      if @event.save
        # Debt:  There's gotta be a beter place for this.  Doesn't work on after_save of events.
        Event.transaction do
          [@event, @event.contact_child_events].flatten.all? { |event| event.set_primary_entity_on_secondary_participations }
          @event.add_note(@event.instance_eval(@event.states(@event.state).meta[:note_text]))
        end
        @event.reload
        @event.try(:address).try(:establish_canonical_address)
        flash[:notice] = 'CMR was successfully created.'
        format.html { 
          query_str = @tab_index ? "?tab_index=#{@tab_index}" : ""
          if go_back
            redirect_to(edit_cmr_url(@event) + query_str)
          else
            redirect_to(cmr_url(@event) + query_str)
          end
        }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    go_back = params.delete(:return)

    # Do this assign and a save rather than update_attributes in order to get the contacts array (at least) properly built
    @event.attributes = params[:morbidity_event]

    # Assume that "save & exits" represent a 'significant' update
    @event.add_note("Edited event") unless go_back

    respond_to do |format|
      if @event.save
        # Debt:  There's gotta be a beter place for this.  Doesn't work on after_save of events.
        Event.transaction do
          [@event, @event.contact_child_events].flatten.all? { |event| event.set_primary_entity_on_secondary_participations }
        end
        flash[:notice] = 'CMR was successfully updated.'
        format.html { 
          query_str = @tab_index ? "?tab_index=#{@tab_index}" : ""
          if go_back
            redirect_to(edit_cmr_url(@event) + query_str)
          else
            redirect_to(cmr_url(@event) + query_str)
          end
        }
        format.xml  { head :ok }
        format.js   { render :inline => "CMR saved.", :status => :created }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.js   { render :inline => "Morbidity Event not saved: <%= @event.errors.full_messages %>", :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    head :method_not_allowed
  end

  def event_search
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => "You do not have privileges to view events" }, :status => 403 and return
    end

    if params[:last_name] || params[:first_name] || params[:birth_date] # Tests to see if any params are supplied in query string.

      # For passing on to new_cmr
      @last_name = params[:last_name]
      @first_name = params[:first_name]
      @birth_date = params[:birth_date]

      # Tests to see if params are supplied but empty
      if @last_name.blank? && @first_name.blank? && @birth_date.blank?
        @results = []
      else
        @birth_date.blank? ? birth_date = nil : birth_date = @birth_date
        params[:page].blank? ? page = 1 : page = params[:page]
        begin
          if params[:use_starts_with_search]
            @results = HumanEvent.search_by_name_and_birth_date_using_starts_with(params[:last_name], params[:first_name], birth_date, {:page_size => 50, :page => page})
          else
            @results = HumanEvent.search_by_name_and_birth_date(params[:last_name] + " " + params[:first_name], birth_date, {:page_size => 50, :page => page})
          end
        rescue
          logger.error $!.message
          flash.now[:error] = 'Unable to process search. Is birth date a valid date?'
        end
      end
    end
  end

  # IE can't handle URLs > 2K so we've added a special method that it can POST to.
  def export
    return unless index_processing
    render :action => "index"
  end

  # IE can't handle URLs > 2K so we've added a special method that it can POST to.
  def export_single
    render :action => "show"
  end

  private
  
  def prepopulate
    @event = setup_human_event_tree(@event)
    # Perhaps include a message if we know the names were split out of a full text search
    @event.interested_party.person_entity.person.first_name = params[:first_name]
    @event.interested_party.person_entity.person.middle_name = params[:middle_name]
    @event.interested_party.person_entity.person.last_name = params[:last_name]
    @event.interested_party.person_entity.person.birth_gender = ExternalCode.find(params[:gender]) unless params[:gender].blank? || params[:gender].to_i == 0
    @event.address.city = params[:city]
    @event.address.county = ExternalCode.find(params[:county]) unless params[:county].blank?
    @event.jurisdiction.secondary_entity_id = params[:jurisdiction_id] unless params[:jurisdiction_id].blank?
    @event.interested_party.person_entity.person.birth_date = params[:birth_date]
  end
  
  def capture_old_attributes
    @old_attributes = @event.attributes
  end

  def index_processing
    if params[:per_page].to_i > 100
      render :text => 'TriSano cannot process more then 100 cmrs per page', :layout => 'application', :status => 400
      return false
    end

    begin
      @export_options = params[:export_options]

      @events = MorbidityEvent.find_all_for_filtered_view(
        :states => params[:states],
        :queues => params[:queues],
        :investigators => params[:investigators],
        :diseases => params[:diseases],
        :order_by => params[:sort_order],
        :do_not_show_deleted => params[:do_not_show_deleted],
        :set_as_default_view => params[:set_as_default_view],
        :page => params[:page],
        :per_page => params[:per_page]
      )
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => 'application', :status => 404 
      return false
    end
    return true
  end

end
