require 'spec_helper'
require 'acts_as_fu'
RSpec.configure do |config|
  config.include ActsAsFu
end

describe EventCalendar::EventInstanceMethods do
  before(:each) do
    build_model :fake_event do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env.to_sym])
      string :name
      datetime :start_on
      datetime :end_on
      string :timezone
      
      include EventCalendar::EventInstanceMethods
    end
  end
  let(:event) do
    FakeEvent.new({
      :name => 'One Day',
      :start_on => Time.now,
      :end_on => Time.now,
      :timezone => "Pacific Time (US & Canada)"
    })
  end
  
  context "distinguishing one day events from the rest" do
    it "given a start_on & end_on, compare day, month and year" do
      event.one_day?.should be_true
      event.end_on = 1.day.from_now
      event.one_day?.should be_false
    end
    it "given only a start_on, return true" do
      event.end_on = nil
      event.one_day?.should be_true
    end
    it "given only a end_on, ... return true" do
      event.start_on = nil
      event.one_day?.should be_true
    end
  end
  
  it "knows start|end_day" do
    event.start_day.should eq Date.today.day
    event.end_day.should eq Date.today.day
  end
  
  it "knows start|end_month" do
    event.start_month.should eq Date.today.strftime('%B')
    event.end_month.should eq Date.today.strftime("%B")
  end
  
  it "knows start|end_year" do
    event.start_year.should eq Date.today.year
    event.end_year.should eq Date.today.year
  end
end
