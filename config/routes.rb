Rails.application.routes.draw do
  devise_for :users, skip: [:registrations, :sessions], controllers: {
    passwords: 'passwords'
  }

  # Health check for Fly.io
  get "up" => "rails/health#show", as: :rails_health_check
  # Simple backup health endpoint
  get "health" => proc { [200, {}, ["OK"]] }

  # Error pages
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unprocessable_entity"
  get "/500", to: "errors#internal_server_error"

  # Test routes for error pages (development only)
  if Rails.env.development?
    get "/test-404", to: "errors#test_404"
    get "/test-500", to: "errors#test_500"
  end

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
    resources :companies
    
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
      member do
        post :activate
        post :reset_password
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
        get 'hardcoded/:template_path', to: 'email_templates#show_hardcoded', as: 'show_hardcoded', constraints: { template_path: /.*/ }
        post 'hardcoded/:template_path/test', to: 'email_templates#send_test_email', as: 'send_test_hardcoded', constraints: { template_path: /.*/ }
      end
    end
    
    # Admin Notification Preferences
    resources 'notification-preferences', only: [:show, :edit, :update], controller: 'notification_preferences', as: 'notification_preferences'
    
    # Content Management Dashboard
    get 'content-management', to: 'content_management#index', as: 'content_management'
    
    # Content Management
    resources 'content-blocks', controller: 'content_blocks', as: 'content_blocks'
    
    # Reviews Management
    resources :reviews, only: [:index, :show, :edit, :update, :destroy] do
      member do
        patch :approve
        patch :unapprove
        patch :toggle_featured
      end
    end
    
    # Review Invites Management
    resources 'review-invites', controller: 'review_invites', as: 'review_invites' do
      member do
        patch :resend
      end
      collection do
        delete :bulk_cleanup
        get :quick_link
        post :create_quick_link
        get :quick_link_created
      end
    end
  end

  # Catch-all route for 404 errors - MUST be last
  # Exclude assets, packs, and other static files
  match '*path', to: 'errors#not_found', via: :all, constraints: lambda { |req|
    !req.path.start_with?('/assets/') && 
    !req.path.start_with?('/packs/') && 
    !req.path.start_with?('/images/') && 
    !req.path.start_with?('/javascripts/') && 
    !req.path.start_with?('/stylesheets/') &&
    !req.path.match(/\.(png|jpg|jpeg|gif|svg|css|js|ico|woff|woff2|ttf|eot|webp)$/i)
  }
end