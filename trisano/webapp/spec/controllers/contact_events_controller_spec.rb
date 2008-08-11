require File.dirname(__FILE__) + '/../spec_helper'

describe ContactEventsController do
  before(:each) do
    mock_user
  end

  describe "handling GET /events" do

    before(:each) do
    end
  
    def do_get
      get :index
    end
  
    it "should return a 405" do
      do_get
      response.code.should == "405"
    end

  describe "handling GET /events/1 with view entitlement" do

    before(:each) do
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).with(:view_event, 75).and_return(true)
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).once().with("75").and_return(@event)
      do_get
    end
  
    it "should assign the found event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end
  
  describe "handling GET /events/1 without view entitlement" do

    before(:each) do
      @event = mock_event
      Event.stub!(:find).and_return(@event)
      @user.stub!(:is_entitled_to_in?).with(:view_event, 75).and_return(false)
    end
  
    def do_get
      get :show, :id => "75"
    end

    it "should be be a 403" do
      do_get
      response.response_code.should == 403
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).with("75").and_return(@event)
      do_get
    end
  
  end
  
  describe "handling GET /events/new" do
  
    def do_get
      get :new
    end
  
    it "should return a 405" do
      do_get
      response.code.should == "405"
    end
  
  end

  describe "handling GET /events/1/edit with update entitlement" do

    before(:each) do
      @event = mock_event
      @form_reference = mock_model(FormReference)
      @form = mock_model(Form, :null_object => true)

      Event.stub!(:find).and_return(@event)
      @event.stub!(:get_investigation_forms).and_return([@form])
      @user.stub!(:is_entitled_to_in?).with(:update_event, 75).and_return(true)
    end
  
    def do_get
      get :edit, :id => "75"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).and_return(@event)
      do_get
    end
  
    it "should assign the found ContactEvent for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  #  describe "handling POST /events" do
  #
  #    before(:each) do
  #      @event = mock_model(ContactEvent, :to_param => "1")
  #      ContactEvent.stub!(:new).and_return(@event)
  #    end
  #    
  #    describe "with successful save" do
  #  
  #      def do_post
  #        @event.should_receive(:save).and_return(true)
  #        post :create, :event => {}
  #      end
  #  
  #      it "should create a new event" do
  #        ContactEvent.should_receive(:new).with({}).and_return(@event)
  #        do_post
  #      end
  #
  #      it "should redirect to the new event" do
  #        do_post
  #        response.should redirect_to(event_url("1"))
  #      end
  #      
  #    end
  #    
  #    describe "with failed save" do
  #
  #      def do_post
  #        @event.should_receive(:save).and_return(false)
  #        post :create, :event => {}
  #      end
  #  
  #      it "should re-render 'new'" do
  #        do_post
  #        response.should render_template('new')
  #      end
  #      
  #    end
  #  end
  #
  #  describe "handling PUT /events/1" do
  #
  #    before(:each) do
  #      @event = mock_model(ContactEvent, :to_param => "1")
  #      ContactEvent.stub!(:find).and_return(@event)
  #    end
  #    
  #    describe "with successful update" do
  #
  #      def do_put
  #        @event.should_receive(:update_attributes).and_return(true)
  #        put :update, :id => "1"
  #      end
  #
  #      it "should find the event requested" do
  #        ContactEvent.should_receive(:find).with("1").and_return(@event)
  #        do_put
  #      end
  #
  #      it "should update the found event" do
  #        do_put
  #        assigns(:event).should equal(@event)
  #      end
  #
  #      it "should assign the found event for the view" do
  #        do_put
  #        assigns(:event).should equal(@event)
  #      end
  #
  #      it "should redirect to the event" do
  #        do_put
  #        response.should redirect_to(event_url("1"))
  #      end
  #
  #    end
  #    
  #    describe "with failed update" do
  #
  #      def do_put
  #        @event.should_receive(:update_attributes).and_return(false)
  #        put :update, :id => "1"
  #      end
  #
  #      it "should re-render 'edit'" do
  #        do_put
  #        response.should render_template('edit')
  #      end
  #
  #    end
  #  end
  #
  #  describe "handling DELETE /events/1" do
  #
  #    before(:each) do
  #      @event = mock_model(ContactEvent, :destroy => true)
  #      ContactEvent.stub!(:find).and_return(@event)
  #    end
  #  
  #    def do_delete
  #      delete :destroy, :id => "1"
  #    end
  #
  #    it "should find the event requested" do
  #      ContactEvent.should_receive(:find).with("1").and_return(@event)
  #      do_delete
  #    end
  #  
  #    it "should call destroy on the found event" do
  #      @event.should_receive(:destroy)
  #      do_delete
  #    end
  #  
  #    it "should redirect to the events list" do
  #      do_delete
  #      response.should redirect_to(events_url)
  #    end
  #  end

  end
end