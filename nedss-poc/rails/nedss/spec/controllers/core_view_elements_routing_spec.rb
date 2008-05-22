require File.dirname(__FILE__) + '/../spec_helper'

describe CoreViewElementsController do
  describe "route generation" do

    it "should map { :controller => 'core_view_elements', :action => 'index' } to /core_view_elements" do
      route_for(:controller => "core_view_elements", :action => "index").should == "/core_view_elements"
    end
  
    it "should map { :controller => 'core_view_elements', :action => 'new' } to /core_view_elements/new" do
      route_for(:controller => "core_view_elements", :action => "new").should == "/core_view_elements/new"
    end
  
    it "should map { :controller => 'core_view_elements', :action => 'show', :id => 1 } to /core_view_elements/1" do
      route_for(:controller => "core_view_elements", :action => "show", :id => 1).should == "/core_view_elements/1"
    end
  
    it "should map { :controller => 'core_view_elements', :action => 'edit', :id => 1 } to /core_view_elements/1/edit" do
      route_for(:controller => "core_view_elements", :action => "edit", :id => 1).should == "/core_view_elements/1/edit"
    end
  
    it "should map { :controller => 'core_view_elements', :action => 'update', :id => 1} to /core_view_elements/1" do
      route_for(:controller => "core_view_elements", :action => "update", :id => 1).should == "/core_view_elements/1"
    end
  
    it "should map { :controller => 'core_view_elements', :action => 'destroy', :id => 1} to /core_view_elements/1" do
      route_for(:controller => "core_view_elements", :action => "destroy", :id => 1).should == "/core_view_elements/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'core_view_elements', action => 'index' } from GET /core_view_elements" do
      params_from(:get, "/core_view_elements").should == {:controller => "core_view_elements", :action => "index"}
    end
  
    it "should generate params { :controller => 'core_view_elements', action => 'new' } from GET /core_view_elements/new" do
      params_from(:get, "/core_view_elements/new").should == {:controller => "core_view_elements", :action => "new"}
    end
  
    it "should generate params { :controller => 'core_view_elements', action => 'create' } from POST /core_view_elements" do
      params_from(:post, "/core_view_elements").should == {:controller => "core_view_elements", :action => "create"}
    end
  
    it "should generate params { :controller => 'core_view_elements', action => 'show', id => '1' } from GET /core_view_elements/1" do
      params_from(:get, "/core_view_elements/1").should == {:controller => "core_view_elements", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'core_view_elements', action => 'edit', id => '1' } from GET /core_view_elements/1;edit" do
      params_from(:get, "/core_view_elements/1/edit").should == {:controller => "core_view_elements", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'core_view_elements', action => 'update', id => '1' } from PUT /core_view_elements/1" do
      params_from(:put, "/core_view_elements/1").should == {:controller => "core_view_elements", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'core_view_elements', action => 'destroy', id => '1' } from DELETE /core_view_elements/1" do
      params_from(:delete, "/core_view_elements/1").should == {:controller => "core_view_elements", :action => "destroy", :id => "1"}
    end
  end
end