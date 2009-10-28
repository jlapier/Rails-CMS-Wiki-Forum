require 'spec_helper'

describe "/categories/show.html.erb" do
  include CategoriesHelper
  before(:each) do
    assigns[:category] = @category = stub_model(Category)
  end

  it "renders attributes in <p>" do
    render
  end
end
