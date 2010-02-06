require 'spec_helper'

describe "/wikis/edit.html.erb" do
  include WikisHelper

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs.merge({:is_admin? => true}))
  end

  before(:each) do
    assigns[:wiki] = @wiki = stub_model(Wiki,
      :new_record? => false,
      :name => "Some page",
      :url_name => "Some_page"
    )
    template.stub!(:current_user).and_return(mock_user)
  end

  it "renders the edit wiki form" do
    render

    response.should have_tag("form[action=#{wiki_path(@wiki)}][method=post]") do
      with_tag 'input#wiki_name[name=?]', 'wiki[name]'
    end
  end
end
