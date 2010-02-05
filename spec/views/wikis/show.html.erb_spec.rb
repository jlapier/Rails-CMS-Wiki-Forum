require 'spec_helper'

describe "/wikis/show.html.erb" do
  include WikisHelper
  before(:each) do
    assigns[:wiki] = @wiki = stub_model(Wiki)
  end

  it "renders attributes in <p>" do
    render
  end
end
