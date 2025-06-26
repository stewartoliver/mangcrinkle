Rails.application.routes.draw do
  devise_for :users, skip: [:registrations, :sessions], controllers: {
    passwords: 'devise/passwords'
  }

  # Public routes
  root 'pages#home'
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  
  resources :products, only: [:index, :show]
  resources :orders, only: [:new, :create, :show]
  
  # Reviews routes
  resources :reviews, only: [:index, :show, :new, :create]

  # Cart routes
  resource :cart, only: [:show], controller: 'cart' do
    collection do
      post :add_product
      post :add_package
      patch :update_quantity
      delete :remove_item
      delete :clear
    end
  end

  # Admin routes
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    
    resources :products
    resources :crinkle_packages
    
    resources :orders, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      collection do
        post :bulk_update
        get :export
      end
    end
    
    resources :users, except: [:destroy] do
      collection do
        get :search
      end
    end
    
    # Content Management Dashboard
    get 'content_management', to: 'content_management#index'
    
    # Content Management
    resources :content_blocks
    
    # Company Management
    resources :companies
    
    # Reviews Management
    resources :reviews, except: [:new, :create] do
      member do
        patch :approve
        patch :unapprove
        patch :feature
        patch :unfeature
      end
      
      collection do
        patch :bulk_approve
        patch :bulk_unapprove
        patch :bulk_feature
        patch :bulk_unfeature
        delete :bulk_destroy
      end
    end
  end
end