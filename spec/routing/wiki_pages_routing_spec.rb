require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiPagesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "wiki_pages", :action => "index", :wiki_id => "1").should ==
        "/wikis/1/wiki_pages"
    end

    it "maps #new" do
      route_for(:controller => "wiki_pages", :action => "new", :wiki_id => "1").should ==
        "/wikis/1/wiki_pages/new"
    end

    it "maps #show" do
      route_for(:controller => "wiki_pages", :action => "show", :id => "1", :wiki_id => "1").should ==
        "/wikis/1/wiki_pages/1"
    end

    it "maps #edit" do
      route_for(:controller => "wiki_pages", :action => "edit", :id => "1", :wiki_id => "1").should ==
        "/wikis/1/wiki_pages/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "wiki_pages", :action => "create", :wiki_id => "1").should ==
        {:path => "/wikis/1/wiki_pages", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "wiki_pages", :action => "update", :id => "1", :wiki_id => "1").should ==
        {:path =>"/wikis/1/wiki_pages/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "wiki_pages", :action => "destroy", :id => "1", :wiki_id => "1").should ==
        {:path =>"/wikis/1/wiki_pages/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/wikis/1/wiki_pages").should ==
        {:controller => "wiki_pages", :action => "index", :wiki_id => "1"}
    end

    it "generates params for #new" do
      params_from(:get, "/wikis/1/wiki_pages/new").should ==
        {:controller => "wiki_pages", :action => "new", :wiki_id => "1"}
    end

    it "generates params for #create" do
      params_from(:post, "/wikis/1/wiki_pages").should ==
        {:controller => "wiki_pages", :action => "create", :wiki_id => "1"}
    end

    it "generates params for #show" do
      params_from(:get, "/wikis/1/wiki_pages/1").should ==
        {:controller => "wiki_pages", :action => "show", :id => "1", :wiki_id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/wikis/1/wiki_pages/1/edit").should ==
        {:controller => "wiki_pages", :action => "edit", :id => "1", :wiki_id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/wikis/1/wiki_pages/1").should ==
        {:controller => "wiki_pages", :action => "update", :id => "1", :wiki_id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/wikis/1/wiki_pages/1").should ==
        {:controller => "wiki_pages", :action => "destroy", :id => "1", :wiki_id => "1"}
    end
  end
end
