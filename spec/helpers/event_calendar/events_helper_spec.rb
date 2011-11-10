require 'spec_helper'

describe EventCalendar::EventsHelper do
  describe "time_with_zones (singular)" do
    it "returns times" do
      time = Time.now
      helper.time_with_zones(time).should eq [
        ["Eastern", time.in_time_zone("Eastern Time (US & Canada)").strftime(TIME_BASE)],
        ["Central", time.in_time_zone("Central Time (US & Canada)").strftime(TIME_BASE)],
        ["Mountain", time.in_time_zone("Mountain Time (US & Canada)").strftime(TIME_BASE)],
        ["Pacific", time.in_time_zone("Pacific Time (US & Canada)").strftime(TIME_BASE)]
      ]
    end
  end
  
  describe "open_if_current_month..." do
    let(:month_names) do
      %w(January February March April May June July August September October
        November December)
    end
    let(:current_month){Date.current.strftime("%B")}
    let(:non_current_month){month_names.select{|m| m != current_month}.first}
    it "returns 'closed' given a non-current-month and nil open_or_closed" do
      helper.open_if_current_month(non_current_month, nil).should eq 'closed'
    end
    it "returns 'open' given a current-month and any open_or_closed" do
      helper.open_if_current_month(current_month, nil).should eq 'open'
      helper.open_if_current_month(current_month, 'closed').should eq 'open'
      helper.open_if_current_month(current_month, 'open').should eq 'open'
    end
    it "returns given open_or_closed when it is not nil and a non-current-month" do
      helper.open_if_current_month(non_current_month, 'open').should eq 'open'
      helper.open_if_current_month(non_current_month, 'closed').should eq 'closed'
    end
  end
end
