require 'spec_helper'

describe "/themes/css" do
  before(:each) do
    assign(:override, 'body { background: #F00; }')
    assign(:timestamp, 12345678)
  end

  it "renders a css file" do
    render
    rendered.should =~  /CSS override: 12345678/
    rendered.should =~  /body \{ background: #F00; \}/
  end
end
