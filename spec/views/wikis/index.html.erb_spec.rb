require 'spec_helper'

describe "/wikis/index.html.erb" do
  include WikisHelper

  before(:each) do
    assigns[:wikis] = [
      stub_model(Wiki),
      stub_model(Wiki)
    ]
  end

  it "renders a list of wikis" do
    render
  end
end
