require 'spec_helper'

describe "/wikis/new.html.erb" do
  include WikisHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:wiki] = stub_model(Wiki,
      :new_record? => true,
      :name => "Some page",
      :url_name => "Some_page"
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders new wiki form" do
    render

    response.should have_tag("form[action=?][method=post]", wikis_path) do
      with_tag 'input#wiki_name[name=?]', 'wiki[name]'
    end
  end
end
