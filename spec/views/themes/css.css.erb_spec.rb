require 'spec_helper'

describe "/themes/css" do
  before(:each) do
    assigns[:css_override] = 'body { background: #F00; }'
    assigns[:css_override_timestamp] = 12345678
  end

  it "renders a css file" do
    render 'themes/css.css.erb'
    response.should =~  /CSS override: 12345678/
    response.should =~  /body \{ background: #F00; \}/
  end
end
