require 'spec_helper'

describe WikisController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/wikis" }.should route_to(:controller => "wikis", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/wikis/new" }.should route_to(:controller => "wikis", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/wikis/1" }.should route_to(:controller => "wikis", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/wikis/1/edit" }.should route_to(:controller => "wikis", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/wikis" }.should route_to(:controller => "wikis", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/wikis/1" }.should route_to(:controller => "wikis", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/wikis/1" }.should route_to(:controller => "wikis", :action => "destroy", :id => "1") 
    end
  end
end
