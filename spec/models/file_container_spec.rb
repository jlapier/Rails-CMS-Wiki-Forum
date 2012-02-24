require 'spec_helper'
require 'acts_as_fu'
RSpec.configure do |config|
  config.include ActsAsFu
end

describe FileContainer do
  
  before(:each) do
    build_model :mock_container do
      string :name
    end
  end
  
  it "collects including class names" do
    MockContainer.send :include, FileContainer
    FileContainer.types.should eql [MockContainer]
  end
  it "declares the has_many side of attachable <> file_attachment assoc." do
    MockContainer.should_receive(:has_many)
    MockContainer.send :include, FileContainer
  end
  it "lazy loads :all of each type" do
    MockContainer.should_receive(:where).with(1)
    MockContainer.send :include, FileContainer
    FileContainer.all
  end
end
