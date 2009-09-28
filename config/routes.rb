ActionController::Routing::Routes.draw do |map|
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
    wiki_page.bookmark  'bookmark/:title',  :action => 'bookmark'
    wiki_page.show      ':title',           :action => 'show_by_title'
  end

  map.connect '/tagcloud.:format', :controller => 'wiki_pages', :action => 'tagcloud'


  map.resources :message_posts, :collection => { :search => :get }

  map.resources :forums

  map.resource :account, :controller => "users"
  map.resources :users
  map.resource :user_session
  map.register '/register', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => "new"
  map.root :controller => 'wiki_pages', :action => 'homepage'
end
