require 'spec_helper'

describe "/themes/images" do
  before(:each) do
    render
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    rendered.should have_selector('p') do |scope|
      scope.should contain %r[Find me in app/views/themes/images]
    end
  end
end
