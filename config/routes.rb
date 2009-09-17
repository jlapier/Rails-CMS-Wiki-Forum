ActionController::Routing::Routes.draw do |map|
  map.resources :message_posts, :collection => { :search => :get }

  map.resources :forums

  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session
  map.register '/register', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => "new"
  map.root :controller => 'forums', :action => 'index'
end
