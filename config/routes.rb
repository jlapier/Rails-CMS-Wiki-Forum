ActionController::Routing::Routes.draw do |map|

  map.connect 'themes/:action', :controller => 'themes'
  map.connect 'themes/:action/:name.:format', :controller => 'themes'
  
  map.resources :site_settings, :collection => { :update_site_settings => :post, :admin => :get }

  map.resources :content_pages, :member => { :upload_handler => :post, :delete_asset => :post }, :collection => { :search => :get }

  map.resources :categories

  map.resources :wiki_comments

  map.resources :wiki_pages
  
  map.with_options :controller => 'wiki_pages', :name_prefix => 'wiki_page_', :path_prefix => '/pages' do |wiki_page|
    wiki_page.show_home '',                 :action => 'show_by_title', :title => 'Home'
    wiki_page.homepage  'homepage',         :action => 'homepage'
    wiki_page.chatter   'chatter',          :action => 'chatter'
    wiki_page.edit      'edit/:id',         :action => 'edit'
    wiki_page.new       'new',              :action => 'new'
    wiki_page.index     'index',            :action => 'index'
    wiki_page.tag       'tag/:tag_name',    :action => 'list_by_tag'
    wiki_page.tag_index 'tag_index',        :action => 'tag_index'
    wiki_page.history   'history/:title',   :action => 'history'
    wiki_page.live_search  'live_search',   :action => 'live_search'
    wiki_page.show      ':title',           :action => 'show_by_title'
  end

  map.connect '/tagcloud.:format', :controller => 'wiki_pages', :action => 'tagcloud'


  map.resources :message_posts, :collection => { :search => :get }

  map.resources :forums

  map.resource :account, :controller => "users"
  map.resources :users, :collection => { :reg_pass_required => :get }
  map.resource :user_session
  map.register '/register', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => "new"
  map.root :controller => 'content_pages', :action => 'home'
end
