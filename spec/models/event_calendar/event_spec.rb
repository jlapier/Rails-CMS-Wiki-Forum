require 'spec_helper'

describe EventCalendar::Event do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :event_type => "Meeting",
      :start_on => Date.new(2010,5,5),
      :end_on => Date.new(2010,5,6),
      :location => "value for location",
      :description => "value for description"
    }
    @may_2010 = EventCalendar::Event.create!(@valid_attributes)
    @mar_2100 = EventCalendar::Event.create!(@valid_attributes.merge!({
      :start_on => (365 * 24 * 5).hours.from_now,
      :end_on => ((365 * 24 * 5) + 72).hours.from_now
    }))
    @current = EventCalendar::Event.create!(@valid_attributes.merge!({
      :start_on => 72.hours.ago,
      :end_on => 48.hours.from_now
    }))
  end
  
  it "Event.past finds past events" do
    EventCalendar::Event.past.first.should eql @may_2010
  end
  
  it "Event.future finds future events" do
    EventCalendar::Event.future.first.should eql @mar_2100
  end
  
  it "Event.current finds current events (in progress and future)" do
    EventCalendar::Event.current.should include @current
    EventCalendar::Event.current.should include @mar_2100
  end
  
  it "Event.between finds events between limits" do
    EventCalendar::Event.between((362 * 24 * 5).hours.from_now, ((365 * 24 * 5) + 72).hours.from_now).first.should eql @mar_2100
  end

  it "should create a new instance given valid attributes" do
    EventCalendar::Event.create!(@valid_attributes)
  end

  it "should export to ics from new instance" do
    event = EventCalendar::Event.create!(@valid_attributes)
    event.to_ics.should =~ /BEGIN:VCALENDAR/
  end
  
  it "must start before it can end" do
    event = EventCalendar::Event.new(@valid_attributes)
    event.end_on = 6.months.ago
    event.should_not be_valid
  end
  
  it "adjusts start_on and end_on to utc from timezone when adjust_to_utc == true" do
    Time.zone = 'Pacific Time (US & Canada)' # mimic default rails behavior
    f = '%A %B %d %Y @ %H%M'
    pac_start = 2.hours.from_now
    pac_end = 4.hours.from_now
    event = EventCalendar::Event.new(@valid_attributes.merge!({
      :timezone => 'Pacific Time (US & Canada)',
      :start_on => pac_start,
      :end_on => pac_end
    }))
    event.save!
    event.start_on.strftime(f).should eq pac_start.strftime(f)
    event.end_on.strftime(f).should eq pac_end.strftime(f)
    event.adjust_to_utc = true
    event.save!
    event.start_on.strftime(f).should eq pac_start.utc.strftime(f)
    event.end_on.strftime(f).should eq pac_end.utc.strftime(f)
  end

  it "should find event types" do
    EventCalendar::Event.create!(@valid_attributes)
    EventCalendar::Event.create!(@valid_attributes.merge :event_type => 'Conference')
    EventCalendar::Event.event_types.should == ['Conference', 'Meeting']
  end
  
  it "should create a new version when an attribute is updated" do
    event = EventCalendar::Event.create!(@valid_attributes)
    event.revision_number.should == 0
    event.name = "updated test"
    event.save
    event.revision_number.should == 1
  end
  
  it "should create a new version when using update_attributes" do
    event = EventCalendar::Event.create!(@valid_attributes)
    event.revision_number.should == 0
    event.update_attributes(:name => "updated test")
    event.revision_number.should == 1
  end
  
  it "should not create a new version when no attributes have changed" do
    event = EventCalendar::Event.create!(@valid_attributes)
    event.revision_number.should == 0
    event.name = @valid_attributes[:name]
    event.save
    event.revision_number.should == 0
  end
  context "setting default end_on of start_on + 1.hour if start_on is present and" do
    before(:each) do
      Time.zone = 'Pacific Time (US & Canada)'
    end
    let(:event) do
      EventCalendar::Event.new(@valid_attributes.merge!({
        :timezone => 'Pacific Time (US & Canada)',
        :start_on => 1.hour.from_now,
        :end_on => nil
      }))
    end
    
    it "end_on is blank" do
      event.one_day?.should be_true
      event.valid?
      event.end_on.should eq event.start_on + 1.hour
    end
    it "end_on <= start_on" do
      event.end_on = 4.hours.ago
      event.one_day?.should be_true
      event.valid?
      event.end_on.should eq event.start_on + 1.hour
    end
  end  
end
