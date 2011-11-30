RailsCMSWikiForum::Application.routes.draw do
  get "errors/routing"

  resources :wikis do
    member do
      get :tagcloud
    end
    resources :wiki_pages do
      collection do
        post :live_search
        get :search
      end
      member do
        get :page_link_handler
        post :delete_asset
        post :un_edit
        post :upload_handler
        get :history
      end
    end

    resources :wiki_comments do
      collection do
        get :weekly
        get :daily
      end
    end
  end

  match '/wikis/:wiki_id/page/:title' => 'wiki_pages#show_by_title', :as => :wiki_pages_show_by_title
  match '/wikis/:id/tag/:tag_name' => 'wikis#list_by_tag', :as => :wiki_tag
  
  match 'themes/colors/:name.:format' => 'themes#colors'
  match 'themes/css/:name.:format' => 'themes#css'
  match 'themes/:action' => 'themes'
  match 'themes/:action/:name.:format' => 'themes'

  resources :site_settings do
    collection do
      get :admin
      post :update_site_settings
    end
  end
  
  resource :dashboard do
    member do
      get :event_calendar
      get :blog
    end
  end

  resources :content_pages do
    collection do
      get :search
    end
    member do
      post :delete_asset
      post :un_edit
      post :upload_handler
    end
  end

  resources :categories, :except => [:new] do
    collection do
      post :sort
    end
  end

  match '/tagcloud.:format' => 'wiki_pages#tagcloud'

  resources :forums do
    member do
      #"/forums/1/jf892424thf984u082j309j233/feed.atom"
      get "/:user_credentials/feed" => "forums#show", :as => :feed
      get :search
    end
    resources :message_posts do
      member do
        get "/:user_credentials/feed" => "message_posts#show", :as => :feed
      end
    end
  end

  resource :account, :controller => 'users'
    resources :users do
      collection do
        get :reg_pass_required
      end
      member do
        post :upload_handler
        post :make_admin
        post :unmake_admin
      end
  end

  resources :user_groups do
    collection do
      get :emails
    end
    member do
      post :add_users
      post :drop_user
      get :add_members
    end
  end
  
  namespace :blog do
    get "/" => 'posts#index', :as => :posts
    post "/" => 'posts#create', :as => :posts
    resources :comments do
      member do
        post :approve
      end
    end
    resources :posts do
      collection do
        get :deleted
        put 'revision/:revision_id' => 'posts#restore', :as => :restore
        get 'by/:author_id' => 'posts#index', :as => :by_author
      end
      member do
        get :revisions
        get 'revision/:revision_number' => 'posts#revision', :as => :revision
        put :revert
        post :publish
        post :delete_asset
        post :un_edit
        post :upload_handler
      end
    end
  end
  
  namespace :event_calendar do
    resources :events do
      collection do
        get :search
      end
      resources :attendees
      resources :links
    end
    resources :event_revisions do
      member do
        post :restore
      end
    end
  end
#    resources :events do
#      collection do
#        get :search
#      end
#      resources :attendees
#      resources :links
#    end
#    resources :event_revisions do
#      member do
#        post :restore
#      end
#    end

  resource :user_session
  resources :password_resets
  match '/register' => 'users#new', :as => :register
  match '/login' => 'user_sessions#new', :as => :login
  match '/' => 'content_pages#home'

  match '*a', :to => 'errors#routing'
end
