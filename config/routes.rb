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
  end
end