ActionController::Routing::Routes.draw do |map|
  map.resources :wikis, :member => { :tagcloud => :get, :tag_index => :get } do |wiki|
    wiki.resources :wiki_pages, :member => { :upload_handler => :post, :page_link_handler => :get, :delete_asset => :post,
      :un_edit => :post, :history => :get }, :collection => { :search => :get, :live_search => :post }
    wiki.resources :wiki_comments, :collection => { :daily => :get, :weekly => :get }
  end

  map.wiki_pages_show_by_title '/wikis/:wiki_id/page/:title', :controller => 'wiki_pages', :action => 'show_by_title'
  map.wiki_tag '/wikis/:id/tag/:tag_name',   :controller => 'wikis', :action => 'list_by_tag'

  map.connect 'themes/:action', :controller => 'themes'
  map.connect 'themes/:action/:name.:format', :controller => 'themes'
  
  map.resources :site_settings, :collection => { :update_site_settings => :post, :admin => :get }

  map.resources :content_pages, :member => { :upload_handler => :post, :delete_asset => :post,
    :un_edit => :post }, :collection => { :search => :get }

  map.resources :categories
  
  map.connect '/tagcloud.:format', :controller => 'wiki_pages', :action => 'tagcloud'


  map.resources :forums do |forum|
    forum.resources :message_posts, :collection => { :search => :get }
  end

  map.resource :account, :controller => "users"
  map.resources :users, :collection => { :reg_pass_required => :get }, :member => { :upload_handler => :post }
  map.resources :user_groups, :member => { :drop_user => :post, :add_members => :get, :add_users => :post }
  map.resource :user_session
  map.register '/register', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => "new"
  map.root :controller => 'content_pages', :action => 'home'
end
