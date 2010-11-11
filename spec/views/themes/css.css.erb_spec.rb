require 'spec_helper'

describe "/themes/css" do
  before(:each) do
    assign(:css_override, 'body { background: #F00; }')
    assign(:css_override_timestamp, 12345678)
  end

  it "renders a css file" do
    render
    rendered.should =~  /CSS override: 12345678/
    rendered.should =~  /body \{ background: #F00; \}/
  end
end
