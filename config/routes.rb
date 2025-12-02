Rails.application.routes.draw do
  root 'landing#index'
  get '/about', to: 'landing#about', as: 'about'
  get '/contact', to: 'landing#contact', as: 'contact'
  get '/gallery', to: 'landing#gallery', as: 'gallery'
  get '/terms-of-service', to: 'landing#terms_of_service', as: 'terms_of_service'
  get '/privacy-policy', to: 'landing#privacy_policy', as: 'privacy_policy'

  get '/catalog', to: 'products#index', as: 'catalog'
  resources :products, only: [:index, :show], param: :id
  resources :categories, only: [:show], param: :id
  resources :reviews, only: [:index, :create, :update, :destroy]

  resource :basket, only: [:show, :destroy] do
    post 'add/:product_id', to: 'baskets#add_item', as: :add_item
    patch 'items/:id', to: 'baskets#update_item', as: :update_item
    delete 'items/:id', to: 'baskets#remove_item', as: :remove_item
  end

  resources :orders, param: :order_number, only: [:index, :show, :new, :create] do
    collection do
      get :track
    end
  end

  # Auth routes
  get '/auth/login', to: 'auth#login', as: 'login'
  get '/auth/register', to: 'auth#register', as: 'register'
  post '/auth/register', to: 'auth#register_handle'
  post '/auth/login', to: 'auth#login_handle'
  get '/auth/logout', to: 'auth#logout', as: 'logout'
  get '/auth/forgot-password', to: 'auth#forgot_password', as: 'forgot_password'
  post '/auth/forgot-password', to: 'auth#forgot_password_handle'
  get '/auth/forgot-password-sent', to: 'auth#forgot_password_sent', as: 'forgot_password_sent'
  get '/auth/reset-password/:token', to: 'auth#edit_reset_password', as: 'edit_reset_password'
  post '/auth/reset-password', to: 'auth#update_reset_password', as: 'update_reset_password'

  # Google OAuth
  get '/auth/google', to: 'auth#google_auth', as: 'google_auth'
  get '/auth/google/callback', to: 'auth#google_auth_callback', as: 'google_auth_callback'
  # Support default OmniAuth callback naming
  get '/auth/google_oauth2', to: 'auth#google_auth'
  get '/auth/google_oauth2/callback', to: 'auth#google_auth_callback', as: 'google_oauth2_callback'

  # 2FA routes
  get '/auth/2fa', to: 'auth#two_factor_auth', as: 'auth_2fa'
  post '/auth/2fa/verify', to: 'auth#verify_2fa_login', as: 'verify_2fa_login'

  # Dashboard routes
  get '/dashboard', to: 'dashboard#overview', as: 'dashboard'
  get '/dashboard/account', to: 'dashboard#account', as: 'dashboard_account'
  patch '/dashboard/account', to: 'dashboard#account', as: 'update_dashboard_account'
  get '/dashboard/info', to: 'dashboard#info', as: 'info'
  patch '/dashboard/info', to: 'dashboard#info', as: 'update_info'
  get '/dashboard/orders', to: 'orders#index', as: 'dashboard_orders'
  get '/dashboard/orders/:order_number', to: 'orders#show', as: 'dashboard_order'
  # Legacy redirects for removed dashboard gallery/contact
  get '/dashboard/gallery', to: redirect('/gallery')
  get '/dashboard/contact', to: redirect('/contact')
  
  get '/address_lookup', to: 'address_lookups#show', as: 'address_lookup'

  
  # 2FA management routes
  get '/dashboard/2fa/enable', to: 'dashboard#enable_2fa', as: 'enable_2fa'
  post '/dashboard/2fa/verify', to: 'dashboard#verify_2fa', as: 'verify_2fa'
  delete '/dashboard/2fa/remove', to: 'dashboard#remove_2fa', as: 'remove_2fa'

  # Admin routes
  namespace :admin do
    get '/', to: 'dashboard#overview', as: 'dashboard'
    get '/overview', to: 'dashboard#overview', as: 'overview'
    get '/analytics', to: 'dashboard#analytics', as: 'analytics'
    get '/reports', to: 'dashboard#reports', as: 'reports'

    resources :products do
      member do
        patch :toggle_featured
      end
      collection do
        get :low_stock
      end
    end

    resources :categories

    resources :gallery, only: [:index, :create]
    delete '/gallery', to: 'gallery#destroy', as: 'gallery_destroy'

    resources :media, only: [:index, :create, :destroy]

    resources :orders do
      member do
        patch :update_status
        patch :update_payment_status
      end
    end

    resources :users do
      member do
        delete :remove_2fa
      end
    end
    
    resources :payments, only: [:index] do
      member do
        patch :update
        delete :destroy
        post :refund
      end
    end
    get '/settings', to: 'settings#index', as: 'settings'
    patch '/settings', to: 'settings#update', as: 'update_settings'
    
    # Stripe settings
    get '/stripe-settings', to: 'stripe_settings#index', as: 'stripe_settings'
    patch '/stripe-settings', to: 'stripe_settings#update', as: 'update_stripe_settings'
    
    # Additional admin routes
    resources :seo_settings
    post '/seo_settings/initialize_defaults', to: 'seo_settings#initialize_defaults', as: 'initialize_seo_defaults'
    get '/emails', to: 'emails#index', as: 'emails'
    get '/emails/preview/:template', to: 'emails#preview', as: 'email_preview'
    get '/changelog', to: 'changelog#index', as: 'changelog'
    post '/changelog', to: 'changelog#create', as: 'create_changelog'
    get '/activity/live', to: 'dashboard#activity_live_view', as: 'activity_live_view'
  end

  # Payments routes
  get '/payments/history', to: 'payments#history', as: 'payment_history'
  post '/payments', to: 'payments#create', as: 'create_payment'
  get '/payments/success/:id', to: 'payments#success', as: 'payment_success'
  get '/payments/cancel/:id', to: 'payments#cancel', as: 'payment_cancel'
  post '/payments/webhook', to: 'payments#webhook', as: 'payment_webhook'
  get '/payments/sync', to: 'payments#sync_payment_statuses', as: 'sync_payments'

  # Email verification routes
  get 'verify_email/:token', to: 'auth#verify_email', as: 'verify_email'
  get 'verify_email', to: 'auth#verify_email_page', as: 'verify_email_page'
  post 'resend_verification_email', to: 'auth#resend_verification_email', as: 'resend_verification_email'



  # Misc routes
  post '/application/upload_image', to: 'application#upload_image', as: 'upload_image'
end
