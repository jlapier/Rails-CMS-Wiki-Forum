require 'spec_helper'

describe EventCalendar::EventRevisionsController do
  before do
    controller.stub!(:current_user).and_return(mock_user)
  end

  describe ":index" do
    context "params[:id] is set" do
      it "redirects to the show path" do
        get :index, :id => "1"
        response.should redirect_to event_calendar_event_revision_path("1")
      end
    end
    context "params[:id] is NOT set" do
      before(:each) do
        EventCalendar::EventRevision.stub(:deleted).and_return([mock_event_revision])
      end
      it "loads all deleted events as @deleted_events" do
        EventCalendar::EventRevision.should_receive(:deleted).and_return([mock_event_revision])
        get :index
        assigns[:deleted_events].should == [mock_event_revision]
      end
      it "renders index" do
        get :index
        response.should render_template("event_revisions/index")
      end
    end
  end
  describe ":show, :id => required" do
    before(:each) do
      EventCalendar::EventRevision.stub(:find).and_return(mock_event_revision)
    end
    it "loads an @event_revision" do
      EventCalendar::EventRevision.should_receive(:find).and_return(mock_event_revision)
      get :show, :id => "1"
      assigns[:event_revision].should eql mock_event_revision
    end
    it "renders show" do
      get :show, :id => "1"
      response.should render_template("event_revisions/show")
    end
  end
  describe ":restore" do
    before(:each) do
      mock_event_revision({
        :restore => nil,
        :name => "Last, First"
      })
      EventCalendar::EventRevision.stub(:find).and_return(mock_event_revision)
    end
    it "loads event revision as @event_revision" do
      EventCalendar::EventRevision.should_receive(:find).with("1").and_return(mock_event_revision)
      post :restore, :id => "1"
      assigns[:event_revision].should eql mock_event_revision
    end
    it "restores the @event_revision" do
      mock_event_revision.should_receive(:restore)
      post :restore, :id => "1"
    end
    context "restore succeeds" do
      before(:each) do
        @event_revision.stub(:restore).and_return(true)
        EventCalendar::EventRevision.stub(:find).and_return(@event_revision)
      end
      it "sets a flash[:message]" do
        post :restore, :id => "1"
        flash[:notice].should_not be_nil
      end
      it "redirects to the newly restored event show page" do
        post :restore, :id => "1"
        response.should redirect_to event_calendar_event_path(@event_revision.id)
      end
    end
    context "restore fails" do
      before(:each) do
        @event_revision.stub(:restore).and_return(false)
        EventCalendar::EventRevision.stub(:find).and_return(@event_revision)
      end
      it "sets a flash[:error]" do
        post :restore, :id => "1"
        flash[:error].should_not be_nil
      end
      it "redirects to the event revisions index" do
        post :restore, :id => "1"
        response.should redirect_to event_calendar_event_revisions_path
      end
    end
  end
end
