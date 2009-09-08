require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ForumsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "forums", :action => "index").should == "/forums"
    end

    it "maps #new" do
      route_for(:controller => "forums", :action => "new").should == "/forums/new"
    end

    it "maps #show" do
      route_for(:controller => "forums", :action => "show", :id => "1").should == "/forums/1"
    end

    it "maps #edit" do
      route_for(:controller => "forums", :action => "edit", :id => "1").should == "/forums/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "forums", :action => "create").should == {:path => "/forums", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "forums", :action => "update", :id => "1").should == {:path =>"/forums/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "forums", :action => "destroy", :id => "1").should == {:path =>"/forums/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/forums").should == {:controller => "forums", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/forums/new").should == {:controller => "forums", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/forums").should == {:controller => "forums", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/forums/1").should == {:controller => "forums", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/forums/1/edit").should == {:controller => "forums", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/forums/1").should == {:controller => "forums", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/forums/1").should == {:controller => "forums", :action => "destroy", :id => "1"}
    end
  end
end
