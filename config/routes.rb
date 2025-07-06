Rails.application.routes.draw do
  devise_for :users, skip: [:registrations, :sessions], controllers: {
    passwords: 'devise/passwords'
  }

  # Public routes
  root 'pages#home'
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  get 'contact/success', to: 'pages#contact_success', as: :contact_success
  
  resources :products, only: [:index, :show]
  resources :orders, only: [:new, :create, :show]
  
  # Reviews routes
  resources :reviews, only: [:index, :show, :new, :create]

  # Contact and Newsletter routes
  resources 'contact-messages', only: [:create], controller: 'contact_messages', as: 'contact_messages'
  resources 'newsletter-subscriptions', only: [:create], controller: 'newsletter_subscriptions', as: 'newsletter_subscriptions' do
    collection do
      get 'unsubscribe'
    end
  end

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
    
    resources :products do
      member do
        delete :remove_image
      end
    end
    resources 'crinkle-packages', controller: 'crinkle_packages', as: 'crinkle_packages'
    
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
    
    # Contact Messages Management
    resources 'contact-messages', except: [:new, :create], controller: 'contact_messages', as: 'contact_messages' do
      member do
        post :respond
      end
      collection do
        post :bulk_update
      end
    end
    
    # Email Templates Management
    resources 'email-templates', controller: 'email_templates', as: 'email_templates' do
      member do
        get :preview
        post :preview
      end
      collection do
        post :seed_defaults
      end
    end
    
    # Admin Notification Preferences
    resources 'notification-preferences', only: [:show, :edit, :update], controller: 'notification_preferences', as: 'notification_preferences'
    
    # Content Management Dashboard
    get 'content-management', to: 'content_management#index', as: 'content_management'
    
    # Content Management
    resources 'content-blocks', controller: 'content_blocks', as: 'content_blocks'
    
    # Company Management
    resources :companies
    
    # Reviews Management
    resources :reviews, except: [:new, :create] do
      member do
        patch :approve
        patch :unapprove
        patch :toggle_featured
      end
      
      collection do
        patch :bulk_approve
        patch :bulk_unapprove
        patch :bulk_feature
        patch :bulk_unfeature
        delete :bulk_destroy
      end
    end
    
    # Review Invites Management
    resources 'review-invites', except: [:edit, :update], controller: 'review_invites', as: 'review_invites' do
      member do
        patch :resend
      end
      collection do
        delete :bulk_cleanup
        get :quick_link
        post :create_quick_link
      end
    end
  end
end