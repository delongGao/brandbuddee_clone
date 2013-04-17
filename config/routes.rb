Brandbuddee::Application.routes.draw do
  
  get "invites/index"
  match '/invite' => 'invites#index'
  match '/invite/twitter' => 'invites#twitter'
  match '/invite/facebook' => 'invites#facebook'
  match '/invite/email' => 'invites#email'
  match '/invite/tweet' => 'invites#tweet'
  match '/invite/sendtweet' => 'invites#sendtweet'
  match '/invite/gmail' => 'invites#gmail'
  match '/invite/yahoo' => 'invites#yahoo'
  match '/invite/hotmail' => 'invites#hotmail'
  match '/contacts/failure' => 'invites#failure'
  match '/invite/sendemail' => 'invites#sendemail'
  match '/invite/sendgmail' => 'invites#sendgmail'
  match '/invite/sendyahoo' => 'invites#sendyahoo'
  match '/invite/sendemail2' => 'invites#sendemail2'
  match '/invite/sendemail3' => 'invites#sendemail3'

  root :to => 'welcome#index'

  match '/about' => 'welcome#about'
  match '/terms' => 'welcome#terms'
  match '/privacy' => 'welcome#privacy'
  match '/contact' => 'welcome#contact'
  match '/support/help' => 'welcome#help'
  match '/brands' => 'welcome#brands'
  
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

  match '/campaign_newsletter/push' => 'users#campaign_newsletter'
  match '/campaign_newsletter_confirmation' => 'users#campaign_newsletter_confirmation'
  match '/admin/consolidate_subscribers' => 'welcome#consolidate_subscribers'

  match '/email/unsubscribe' => 'welcome#unsubscribe'
  match '/email/unsubscribe/confirm' => 'welcome#unsubscribe_confirm'

  match 'home' => 'users#dashboard'

  match 'profile/location' => 'profile#update_location'
  match 'profile/settings' => 'profile#profile_settings'
  match 'profile/settings/update' => 'profile#profile_settings_update'
  match 'account/settings' => 'profile#account_settings'
  match 'account/settings/update' => 'profile#account_settings_update'
  match 'account/password/settings' => 'profile#password_settings'
  match 'account/password/settings/update' => 'profile#password_settings_update'
  match '/profile/image/update' => 'profile#update_profile_image'

  match 'password/reset' => 'users#password_reset'
  match 'password/reset/send' => 'users#password_reset_update'
  get "/pw/reset/:hash_code" => 'users#password_reset_submit', :as => :hash_code
  match 'pw/reset/update' => 'users#password_reset_submit_update'

  match "/profile/username" => "profile#profile_nickname_settings"
  match "/profile/username/update" => "profile#profile_nickname_update"

  match '/choose/username' => 'users#choose_username'
  match '/choose/username/update' => 'users#choose_username_update'

  match '/choose/location' => 'users#choose_location'
  match '/choose/location/update' => 'users#choose_location_update'

  match 'admin' => 'admin#index'

  post 'admin/category/create' => 'users#create_new_category'
  match 'admin/category/destroy' => 'users#category_destroy'
  post 'admin/location/create' => 'users#create_new_location'
  match 'admin/location/destroy' => 'users#location_destroy'
  post 'admin/brand/create' => 'users#create_new_brand'
  match 'admin/brand/destroy' => 'users#brand_destroy'
  match 'admin/share/destroy' => 'users#share_destroy'
  match 'admin/redeem/destroy' => 'users#redeem_destroy'

  match 'admin/campaigns' => 'admin#campaigns'
  match 'admin/users' => 'admin#users'

  match 'admin/campaign/new' => 'admin#campaign_new'
  match 'admin/campaign/view' => 'admin#view_campaign'
  match 'admin/campaign/edit' => 'admin#edit_campaign'
  match 'admin/campaign/update' => 'admin#update_campaign'
  match 'admin/campaign/delete' => 'admin#campaign_delete'

  match 'admin/campaign/create' => 'users#create_new_campaign'
  match 'admin/campaign/destroy' => 'users#campaign_destroy'

  match 'admin/campaign/view/users' => 'admin#view_campaign_users'
  match 'admin/campaign/view/redeems' => 'admin#view_campaign_redeems'
  match 'admin/campaign/view/trackings' => 'admin#view_campaign_trackings'

  match 'admin/locations' =>  'admin#locations'
  match 'admin/locations/new' => 'admin#location_new'
  match 'admin/location/delete' => 'admin#location_delete'

  match 'admin/redeems' => 'admin#redeems'

  match 'admin/categories' =>  'admin#categories'
  match 'admin/categories/new' => 'admin#category_new'
  match 'admin/categories/delete' => 'admin#category_delete'

  match 'admin/brands' =>  'admin#brands'
  match 'admin/brands/new' => 'admin#brand_new'
  match 'admin/brand/delete' => 'admin#brand_delete'
  match 'admin/brands/edit' => 'admin#brand_edit'
  match 'admin/brands/update' => 'admin#brand_update'


  match 'superadmin/campaign/edit' => 'campaign#edit_campaign'
  match 'superadmin/campaign/update' => 'campaign#update_campaign'

  match 'admin/brand/edit' => 'users#edit_brand'
  match 'admin/brand/update' => 'users#update_brand'

  match 'admin/redeem/resend_confirmation' => 'campaign#resend_redeem_confirmation_email'

  get "/:profile" => 'profile#index', :as => :profile
  resources :profile, :only => [:index]

  get '/:profile/follow' => 'profile#follow', :as => :follow_id
  get '/:profile/unfollow' => 'profile#unfollow', :as => :unfollow_id

  get '/:profile/follow/update' => 'profile#list_follow'
  get '/:profile/unfollow/update' => 'profile#list_unfollow'

  match 'campaign/activate' => 'campaign#activate_campaign'
  get "/campaign/:campaign" => 'campaign#index', :as => :campaign

  match '/post/facebook' => 'campaign#facebook_wall_post'
  #match '/facebook/connect' => 'users#facebook_connect'

  get "/s/:share" => 'campaign#share', :as => :share

  post 'subscribers/create' => "welcome#create"
  #get 'subscribers/list' => "welcome#list"
  get 'subscribers/list' => "welcome#list"
  get 'subscribers/delete' => "welcome#destroy"

  get 'password_resets/show' => "users#password_resets_show"
  get 'password_resets/delete' => "users#password_resets_destroy"

  match 'subscriber/invite' => "welcome#invite"
  match 'subscriber/invite/destroy' => "welcome#invite_destroy"
  
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
