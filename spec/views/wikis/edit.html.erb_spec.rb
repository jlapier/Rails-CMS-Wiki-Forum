require 'spec_helper'

describe "/wikis/edit.html.erb" do
  include WikisHelper

  before(:each) do
    assigns[:wiki] = @wiki = stub_model(Wiki,
      :new_record? => false
    )
  end

  it "renders the edit wiki form" do
    render

    response.should have_tag("form[action=#{wiki_path(@wiki)}][method=post]") do
    end
  end
end
