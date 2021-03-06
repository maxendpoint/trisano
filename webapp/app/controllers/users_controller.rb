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

class UsersController < AdminController
  skip_before_filter :check_role, :only => [:shortcuts, :shortcuts_edit, :shortcuts_update, 'settings']
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.all :order => {
      'uid ASC'        => 'uid ASC',
      'uid DESC'       => 'uid DESC',
      'status ASC'     => 'status ASC',
      'status DESC'    => 'status DESC',
      'user_name ASC'  => 'user_name ASC',
      'user_name DESC' => 'user_name DESC'
    }["#{params[:sort_by]} #{params[:sort_direction]}"] || 'uid ASC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /users/shortcuts
  def shortcuts
    @user = User.current_user
    response.headers['X-JSON'] = @user.shortcut_settings.to_json
    head :ok
  end
  
  # GET /users/shortcuts/edit
  def shortcuts_edit
    @user = User.current_user
    respond_to do |format|
      format.html
    end
  end
  
  # PUT /users/shortcuts
  def shortcuts_update
    @user = User.current_user

    respond_to do |format|
      if @user.update_attribute(:shortcut_settings, params[:user][:shortcut_settings])
        flash[:notice] = 'Shortcuts successfully updated'
      else
        flash[:error] = 'Shortcuts update failed'
      end
    format.html { render :action => "shortcuts_edit" }
    end
  end

  def settings
    respond_to do |format|
      format.html
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    params[:user][:role_membership_attributes] ||= {}
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    # Delete the following line when deleting users is allowed
    render :text => 'Deleting users is not yet implemented.', :status => 405

    # Uncomment and verify the following lines to enable user deletion
    # @user = User.find(params[:id])
    # @user.destroy
    #
    # respond_to do |format|
    #   format.html { redirect_to(users_url) }
    #   format.xml  { head :ok }
    # end
  end

end
