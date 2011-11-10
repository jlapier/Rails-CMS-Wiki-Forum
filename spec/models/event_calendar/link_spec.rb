require 'spec_helper'

associations = {
  :has_and_belongs_to_many => %w(events)
}

describe EventCalendar::Link do
  subject{ EventCalendar::Link }
  
  let(:link){ EventCalendar::Link.new }
  
  spec_associations(associations, :class => EventCalendar::Link)
  
  describe "a valid Link" do
    before(:all) do
      link.valid?
    end
    it "has a name" do
      link.should have(1).error_on(:name)
    end
    it "has a url" do
      link.errors[:url].should include('can\'t be blank')
    end
    it "has a /valid/ url but will prepend 'http://' by default if no protocol is detected and url is not blank" do
      link.name = 'Test'
      link.url = 'test.com'
      link.valid?.should be_true
      link.url.should eq 'http://test.com'
    end
  end
end
