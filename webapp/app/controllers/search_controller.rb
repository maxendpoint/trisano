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

class SearchController < ApplicationController
  include Blankable

  def index
  end

  def cmrs
    unless User.current_user.is_entitled_to?(:view_event)
      render :partial => 'events/permission_denied', :layout => true, :locals => { :reason => "You do not have privileges to view events" }, :status => 403 and return
    end

    flash[:error] = ""
    error_details = []

    @jurisdictions = User.current_user.jurisdictions_for_privilege(:view_event)
    if @jurisdictions.nil?
      error_details << "You do not have view permissions in any jurisdiction"
    end

    @first_name = ""
    @middle_name = ""
    @last_name = ""
    @birth_date = ""
    @event_types = [ {:name => "Morbidity Event (CMR)", :value => "MorbidityEvent"}, {:name => "Contact Event", :value => "ContactEvent"} ]
    @diseases = Disease.find(:all, :order => "disease_name")
    @genders = ExternalCode.active.find(:all, :select => "id, code_description", :conditions => "code_name = 'gender'")

    @genders << ExternalCode.new(:id => "U", :the_code => "U", :code_description => "Unspecified", :code_name => "gender")

    @workflow_states = MorbidityEvent.get_states_and_descriptions

    @counties = ExternalCode.active.find(:all, :select => "id, code_description", :conditions => "code_name = 'county'")

    begin
      if not params.values_blank?

        if !params[:birth_date].blank?
          begin
            if (params[:birth_date].length == 4 && params[:birth_date].to_i != 0)
              @birth_date = params[:birth_date]
            else
              @birth_date = parse_american_date(params[:birth_date])
            end
          rescue
            error_details << "Invalid birth date format"
          end
        end

        if !params[:entered_on_start].blank?
          begin
            entered_on_start = parse_american_date(params[:entered_on_start])
          rescue
            error_details << "Invalid entered-on start date format"
          end
        end

        if !params[:entered_on_end].blank?
          begin
            entered_on_end = parse_american_date(params[:entered_on_end], 1)
          rescue
            error_details << "Invalid entered-on end date format"
          end
        end

        raise if (!error_details.empty?)

        @cmrs = Event.find_by_criteria(:fulltext_terms => params[:name],
                                       :diseases => params[:diseases],
                                       :gender => params[:gender],
                                       :sw_last_name => params[:sw_last_name],
                                       :sw_first_name => params[:sw_first_name],
                                       :workflow_state => params[:workflow_state],
                                       :birth_date => @birth_date,
                                       :entered_on_start => entered_on_start,
                                       :entered_on_end => entered_on_end,
                                       :city => params[:city],
                                       :county => params[:county],
                                       :jurisdiction_ids => params[:jurisdiction_ids],
                                       :event_type => params[:event_type],
                                       :record_number => params[:record_number],
                                       :pregnant_id => params[:pregnant_id],
                                       :state_case_status_ids => params[:state_case_status_ids],
                                       :lhd_case_status_ids => params[:lhd_case_status_ids],
                                       :sent_to_cdc => params[:sent_to_cdc],
                                       :first_reported_PH_date_start => params[:first_reported_PH_date_start],
                                       :first_reported_PH_date_end => params[:first_reported_PH_date_end],
                                       :investigator_ids => params[:investigator_ids],
                                       :other_data_1 => params[:other_data_1],
                                       :other_data_2 => params[:other_data_2]
                                       )

        if !params[:sw_first_name].blank? || !params[:sw_last_name].blank?
          @first_name = params[:sw_first_name]
          @last_name = params[:sw_last_name]
        elsif !params[:name].blank?
          parse_names_from_fulltext_search
        end

      end
    rescue Exception => ex
      flash[:error] = "There was a problem with your search criteria"

      # Debt: Error display details are pretty weak. Good enough for now.
      if (!error_details.empty?)
        flash[:error] += "<ul>"
        error_details.each do |e|
          flash[:error] += "<li>#{e}</li>"
        end
        flash[:error] += "</ul>"
      end
      logger.error ex
    end

    # For some reason can't communicate with template via :locals on the render line.  @show_answers and @export_options are used for csv export to cause
    # formbuilder answers to be output and limit the repeating elements, respectively.
    if !params[:diseases].blank? and params[:diseases].size == 1
      @show_answers = true
      @disease = Disease.find(params[:diseases][0])
    end

    @export_options = params[:export_options] || []

    respond_to do |format|
      format.html
      format.csv { render :layout => false }
    end

  end

  def auto_complete_model_for_city
    entered_city = params[:city]
    @addresses = Address.find(:all,
      :select => "distinct city",
      :conditions => [ "city ILIKE ?",
        entered_city + '%'],
      :order => "city ASC",
      :limit => 10
    )
    render :inline => '<ul><% for address in @addresses %><li id="city_<%= address.city %>"><%= h address.city  %></li><% end %></ul>'
  end

  private

  def parse_names_from_fulltext_search
    name_list = params[:name].split(" ")
    if name_list.size == 1
      @last_name = name_list[0]
    elsif name_list.size == 2
      @first_name, @last_name = name_list
    else
      @first_name, @middle_name, @last_name = name_list
    end
  end

  def parse_american_date(date, offset = 0)
    american_date = '%m/%d/%Y'
    (Date.strptime(date, american_date) + offset).to_s
  end

end
