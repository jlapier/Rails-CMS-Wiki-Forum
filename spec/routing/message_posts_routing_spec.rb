require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MessagePostsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "message_posts", :action => "index").should == "/message_posts"
    end

    it "maps #new" do
      route_for(:controller => "message_posts", :action => "new").should == "/message_posts/new"
    end

    it "maps #show" do
      route_for(:controller => "message_posts", :action => "show", :id => "1").should == "/message_posts/1"
    end

    it "maps #edit" do
      route_for(:controller => "message_posts", :action => "edit", :id => "1").should == "/message_posts/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "message_posts", :action => "create").should == {:path => "/message_posts", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "message_posts", :action => "update", :id => "1").should == {:path =>"/message_posts/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "message_posts", :action => "destroy", :id => "1").should == {:path =>"/message_posts/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/message_posts").should == {:controller => "message_posts", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/message_posts/new").should == {:controller => "message_posts", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/message_posts").should == {:controller => "message_posts", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/message_posts/1").should == {:controller => "message_posts", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/message_posts/1/edit").should == {:controller => "message_posts", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/message_posts/1").should == {:controller => "message_posts", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/message_posts/1").should == {:controller => "message_posts", :action => "destroy", :id => "1"}
    end
  end
end
