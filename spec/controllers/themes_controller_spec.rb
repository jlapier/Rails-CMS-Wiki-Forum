require 'spec_helper'

describe ThemesController do

  #Delete these examples and add some real ones
  it "should use ThemesController" do
    controller.should be_an_instance_of(ThemesController)
  end


  describe "GET 'colors'" do
    it "should be successful" do
      get 'colors', :format => :css
      response.should be_success
    end
  end

  describe "GET 'css'" do
    it "should be successful" do
      get 'css', :format => :css
      response.should be_success
    end
  end

  describe "GET 'images'" do
    it "should be successful" do
      get 'images'
      response.should be_success
    end
  end
end
