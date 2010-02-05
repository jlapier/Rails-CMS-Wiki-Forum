require 'spec_helper'

describe "/wikis/new.html.erb" do
  include WikisHelper

  before(:each) do
    assigns[:wiki] = stub_model(Wiki,
      :new_record? => true
    )
  end

  it "renders new wiki form" do
    render

    response.should have_tag("form[action=?][method=post]", wikis_path) do
    end
  end
end
