RailsCMSWikiForum::Application.routes.draw do
  resources :wikis do
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
  match 'themes/:action' => 'themes#index'
  match 'themes/:action/:name.:format' => 'themes#index'

  resources :site_settings do
    collection do
      get :admin
      post :update_site_settings
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

  resources :categories

  match '/tagcloud.:format' => 'wiki_pages#tagcloud'

  resources :forums do
    resources :message_posts
  end

  resource :account
    resources :users do
      collection do
        get :reg_pass_required
      end
      member do
        post :upload_handler
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

  resource :user_session
  resources :password_resets
  match '/register' => 'users#new', :as => :register
  match '/login' => 'user_sessions#new', :as => :login
  match '/' => 'content_pages#home'
end
