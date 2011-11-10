require 'spec_helper'

describe EventCalendar::LinksController do
  subject{ EventCalendar::Event }
  let(:stub_link) do
    stub_model(EventCalendar::Link)
  end
  let(:link) do
    mock_model(EventCalendar::Link)
  end
  let(:event) do
    mock_model(EventCalendar::Event, {
      :save! => nil,
      :links => mock('Relation', {
        :build => stub_link
      })
    })
  end
  before(:each) do
    controller.stub!(:current_user).and_return(mock_user)
    subject.stub(:find).and_return(event)
  end
  describe "GET :edit, :event_id => int, :id => int" do
    let(:params) do
      {:event_id => event.id, :id => link.id}
    end
    before(:each) do      
      EventCalendar::Link.should_receive(:find){ link }
    end
    it "loads an @event and @link" do
      get :edit, params
      assigns(:event).should eq event
      assigns(:link).should eq link
    end
    it "renders the edit template" do
      get :edit, params
      response.should render_template('links/edit')
    end
  end
  describe "PUT :update, :event_id => int, :id => int, :link => {}" do
    let(:params) do
      {:event_id => event.id, :id => link.id}
    end
    let(:link_params) do
      {:name => 'Updated', :url => 'example.com/updated.html'}
    end
    before(:each) do
      link.stub(:update_attributes){ nil }
      EventCalendar::Link.should_receive(:find){ link }
    end
    it "loads an @event and @link" do
      put :update, params
      assigns(:event).should eq event
      assigns(:link).should eq link
    end
    it "updates the @link" do
      link.should_receive(:update_attributes).with(link_params.stringify_keys)
      put :update, params.merge!({:link => link_params})
    end
    context "update succeeds :)" do
      before(:each) do
        link.stub(:update_attributes){ true }
      end
      it "sets flash[:notice]" do
        put :update, params
        flash[:notice].should_not be_nil
      end
      it "as http: redirects to @event" do
        put :update, params
        response.should redirect_to event_calendar_event_path(event)
      end
    end
    context "update fails :(" do
      before(:each) do
        link.stub(:update_attributes){ false }
      end
      it "as http: renders the edit template" do
        put :update, params
        response.should render_template('links/edit')
      end
    end
    it "as xhr: renders update.rjs" do
      xhr :put, :update, params
      response.should render_template('links/update')
    end
  end
  describe "POST :create, :event_id => int, :link => {}" do
    let(:params) do
      {:event_id => event.id}
    end
    let(:link_params) do
      {:name => 'Created', :url => 'http://test.com'}
    end
    it "loads an @event" do
      post :create, params
      assigns(:event).should eq event
    end
    it "builds a new link" do
      event.links.should_receive(:build).with(link_params.stringify_keys)
      post :create, params.merge!({:link => link_params})
    end
    it "saves! the @event, without triggering a revision" do
      event.should_receive(:save!).with(:without_revision => true)
      post :create, params
    end
    it "as http: renders events/show if an ActiveRecord::RecordInvalid exception is raised" do
      event.stub(:save!){ raise ActiveRecord::RecordInvalid.new(event) }
      post :create, params
      response.should render_template('events/show')
    end
    it "sets a flash[:notice]" do
      post :create, params
      flash[:notice].should_not be_nil
    end
    it "as http: redirects to the event" do
      post :create, params
      response.should redirect_to event_calendar_event_path(event)
    end
    it "as xhr: renders create.rjs" do
      xhr :post, :create, params
      response.should render_template('links/create')
    end
  end
  describe "DELETE :destroy, :event_id => int, :id => int" do
    let(:params) do
      {:event_id => event.id, :id => link.id}
    end
    before(:each) do
      link.stub(:destroy){ nil }
      EventCalendar::Link.should_receive(:find){ link }
    end
    it "destroys a link" do
      link.should_receive(:destroy)
      delete :destroy, params
    end
    it "as http: redirects to :event_id" do
      delete :destroy, params
      response.should redirect_to event_calendar_event_path event.id
    end
  end
end
