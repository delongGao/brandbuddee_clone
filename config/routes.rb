Brandbuddee::Application.routes.draw do
  
  root :to => 'welcome#index'
  
  match '/signout' => 'sessions#destroy' #, :as => "signout"
  post '/signin' => 'sessions#email_create'
  match 'login' => 'sessions#new'
  match "/signup" => 'users#new' #, :as => "signup"
  match '/auth/:provider/callback' => 'sessions#create'
  
  post 'users/create' => "users#create"
  match 'users/show' => 'users#show'
  match 'users/destroy' => 'users#destroy'
  
  match 'complete/email' => 'users#complete_email'
  match 'complete/email/update' => 'users#complete_email_update'

  match 'dashboard' => 'users#dashboard'

  match 'profile/settings' => 'profile#profile_settings'
  match 'profile/settings/update' => 'profile#profile_settings_update'
  match 'account/settings' => 'profile#account_settings'
  match 'account/settings/update' => 'profile#account_settings_update'
  match '/profile/image/update' => 'profile#update_profile_image'

  match "/profile/username" => "profile#profile_nickname_settings"
  match "/profile/username/update" => "profile#profile_nickname_update"

  post 'admin/category/create' => 'users#create_new_category'
  match 'admin/category/destroy' => 'users#category_destroy'
  post 'admin/brand/create' => 'users#create_new_brand'
  match 'admin/brand/destroy' => 'users#brand_destroy'
  match 'admin/share/destroy' => 'users#share_destroy'
  match 'admin/redeem/destroy' => 'users#redeem_destroy'

  match 'admin/campaign/create' => 'users#create_new_campaign'
  match 'admin/campaign/destroy' => 'users#campaign_destroy'

  get "/:profile" => 'profile#index', :as => :profile
  resources :profile, :only => [:index]

  match 'campaign/activate' => 'campaign#activate_campaign'
  get "/campaign/:campaign" => 'campaign#index', :as => :campaign

  get "/s/:share" => 'campaign#share', :as => :share

  post 'subscribers/create' => "welcome#create"
  #get 'subscribers/list' => "welcome#list"
  get 'subscribers/list' => "welcome#list"
  get 'subscribers/delete' => "welcome#destroy"
  
  get "/b/:share_link" => "welcome#share"
  get "/share" => "welcome#share"
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
