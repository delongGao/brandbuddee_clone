Brandbuddee::Application.routes.draw do
  get "invites/index"
  match '/invite' => 'invites#index'
  match '/invite/facebook' => 'invites#facebook'
  match '/invite/email' => 'invites#email'
  match '/invite/gmail' => 'invites#gmail'
  match '/invite/yahoo' => 'invites#yahoo'
  match '/contacts/failure' => 'invites#failure'
  match '/invite/sendemail' => 'invites#sendemail'
  match '/invite/sendgmail' => 'invites#sendgmail'
  match '/invite/sendyahoo' => 'invites#sendyahoo'
  match '/invite/sendemail2' => 'invites#sendemail2'
  match '/invite/sendemail3' => 'invites#sendemail3'
  match '/invite/facebook_search' => 'invites#facebook_search'
  match '/fb-like-gate' => 'embed_widgets#facebook_like_gate'
  match '/fb-embed-admin' => 'embed_widgets#facebook_admin_page'
  match '/fb-campaign-embed' => 'embed_widgets#facebook_index'
  match '/fb-embed-signup' => 'embed_widgets#facebook_signup'
  match '/fb-embed-create' => 'embed_widgets#facebook_create'
  match '/fb-embed-login' => 'embed_widgets#facebook_email_signin'
  match '/fb-joined-campaign' => 'embed_widgets#facebook_joined_camp'
  match '/fb-error-page' => 'embed_widgets#facebook_error_page'
  match '/fb-create-username' => 'embed_widgets#facebook_create_username'
  match '/fb-update-username' => 'embed_widgets#facebook_update_username'
  match '/fb-add-campaign' => 'embed_widgets#facebook_add_campaign'
  match '/fb-wall-post' => 'embed_widgets#facebook_wall_post'
  match '/fb-task-complete' => 'embed_widgets#facebook_task_complete'
  match '/fb-task-undo' => 'embed_widgets#facebook_task_undo'
  match '/fb-invite-fb-list' => 'embed_widgets#invite_facebook_list'
  match '/fb-invite-fb-search' => 'embed_widgets#invite_facebook_search'
  match '/fb-invite-email-form' => 'embed_widgets#invite_email_form'
  match '/fb-invite-email-send' => 'embed_widgets#invite_email_send'
  match '/fb-auth-cancelled' => 'embed_widgets#facebook_auth_cancelled'
  match '/fb-update-user-token' => 'embed_widgets#facebook_update_user_token'

  root :to => 'welcome#index'

  match '/about' => 'welcome#about'
  match '/terms' => 'welcome#terms'
  match '/privacy' => 'welcome#privacy'
  match '/contact' => 'welcome#contact'
  match '/support/help' => 'welcome#help'
  match '/brands' => 'welcome#brands'
  match '/tell-me-more' => 'welcome#tell_me_more'
  match '/faq' => 'welcome#faq'
  match '/sample-campaign' => 'welcome#sample_campaign'
  match '/end-buddee-tour' => 'welcome#destroy_tour_cookie'
  match '/begin-buddee-tour' => 'welcome#create_tour_cookie'
  
  match '/signout' => 'sessions#destroy' #, :as => "signout"
  post '/signin' => 'sessions#email_create'
  match 'login' => 'sessions#new'
  match "/signup" => 'users#new' #, :as => "signup"
  match '/auth/:provider/callback' => 'sessions#create'
  
  post 'users/create' => "users#create"
  match 'users/destroy' => 'users#destroy'

  match '/brands/signup' => 'welcome#new_brand'
  match '/brands/create' => 'welcome#create_brand'
  match '/brands/facebook' => 'brands#facebook_auth'
  match '/brands/twitter' => 'brands#twitter_auth'
  match '/brands/login' => 'sessions#brand_login'
  match '/brands/email-login' => 'sessions#brand_email_login'
  match '/brands/dashboard' => 'brands#dashboard'
  match '/brands/logout' => 'sessions#brand_destroy'
  match '/brands/profile' => 'brands#view_edit_profile'
  match '/brands/enter-email' => 'welcome#brands_get_email'
  match '/brands/update-email' => 'welcome#brands_update_email'
  match '/brands/enter-nickname' => 'welcome#brands_get_nickname'
  match '/brands/update-nickname' => 'welcome#brands_update_nickname'
  match '/brands/update-profile' => 'brands#update_profile'
  match '/brands/change-password' => 'brands#change_password'
  match '/brands/update-password' => 'brands#update_password'
  match '/brands/change-email' => 'brands#change_email'
  match '/brands/update-email-address' => 'brands#update_email'
  match '/brands/campaigns' => 'brands#list_campaigns'
  match '/brands/campaigns/create' => 'brands#create_campaign'
  match '/brands/campaigns/view' => 'brands#view_campaign'
  match '/brands/campaigns/buddees' => 'brands#view_campaign_buddees'
  match '/brands/campaigns/redeems' => 'brands#view_campaign_redeems'
  match '/brands/campaigns/tasks' => 'brands#view_campaign_tasks'
  match '/brands/redeems' => 'brands#all_redeems'
  match '/brands/go-viral' => 'brands#go_viral_page'
  match '/brands/campaigns/viral' => 'brands#viral_campaign_picked'
  match '/brands/campaigns/viral-install-fb' =>'brands#viral_campaign_install_fb'
  match '/brands/campaigns/viral-page-chosen' => 'brands#viral_campaign_fb_page_chosen'
  match '/brands/facebook-re-connect' => 'brands#facebook_reconnect'
  match '/brands/campaigns/viral-invite-email' => 'brands#viral_invite_email'
  match '/brands/campaigns/viral-invite-facebook' => 'brands#viral_invite_facebook'
  match '/brands/campaigns/viral-invite-fb-search' => 'brands#viral_invite_fb_search'
  match '/brands/campaigns/viral-invite-email-send' => 'brands#viral_invite_email_send'
  match '/brands/tour' => 'brands#start_brand_tour'
  match '/brands/end-tour' => 'brands#end_brand_tour'
  match '/brands/sample-pages/campaigns' => 'brands#sample_campaign_list'
  match '/brands/sample-pages/view-campaign' => 'brands#sample_campaign_view'
  match '/brands/sample-pages/viral-embed' => 'brands#sample_viral_embed'
  match '/brands/sample-pages/view-redeems' => 'brands#sample_redeems_view'
  match '/brands/sample-pages/view-tasks' => 'brands#sample_tasks_view'
  match '/brands/update-fb-token' => 'brands#update_fb_token_via_ajax'
  match '/brands/campaigns/story-auth' => 'brands#story_auth'
  match '/brands/campaigns/story-page-chosen' => 'brands#story_campaign_fb_page_chosen'
  match '/brands/campaigns/story-chosen' => 'brands#story_chosen'
  #resources :brands
  
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

  match 'admin/campaigns' => 'admin#campaigns'
  match 'admin/users' => 'admin#users'

  match 'admin/campaign/new' => 'admin#campaign_new'
  match '/admin/campaign/new-index' => 'admin#campaign_new_index'
  match '/admin/campaign/apply-crop' => 'admin#campaign_apply_crop'
  match 'admin/campaign/view' => 'admin#view_campaign'
  match 'admin/campaign/edit' => 'admin#edit_campaign'
  match 'admin/campaign/update' => 'admin#update_campaign'
  match 'admin/campaign/delete' => 'admin#campaign_delete'

  match 'admin/campaign/view/users' => 'admin#view_campaign_users'
  match 'admin/campaign/view/redeems' => 'admin#view_campaign_redeems'
  match 'admin/campaign/view/trackings' => 'admin#view_campaign_trackings'
  match 'admin/campaign/view/tasks' => 'admin#view_campaign_tasks'

  match 'admin/locations' =>  'admin#locations'
  match 'admin/locations/new' => 'admin#location_new'
  match 'admin/location/delete' => 'admin#location_delete'

  match 'admin/redeems' => 'admin#redeems'

  match 'admin/categories' =>  'admin#categories'
  match 'admin/categories/new' => 'admin#category_new'
  match 'admin/categories/delete' => 'admin#category_delete'

  match 'admin/brands' =>  'admin#brands'
  match '/admin/brands/new-index' => 'admin#brand_new_index'
  match 'admin/brands/new' => 'admin#brand_new'
  match 'admin/brand/delete' => 'admin#brand_delete'
  match 'admin/brands/edit' => 'admin#brand_edit'
  match 'admin/brands/update' => 'admin#brand_update'
  match '/admin/brands/select-brand-to-convert' => 'admin#select_brand_to_convert'
  match '/admin/brands/convert-old-to-new' => 'admin#convert_old_account_to_new'
  match '/admin/brands/give-old-brand-profile' => 'admin#give_old_brand_profile'

  match 'admin/redeem/resend_confirmation' => 'campaign#resend_redeem_confirmation_email'

  get "/:profile" => 'profile#index', :as => :profile
  resources :profile, :only => [:index]

  get '/:profile/follow' => 'profile#follow', :as => :follow_id
  get '/:profile/unfollow' => 'profile#unfollow', :as => :unfollow_id

  get '/:profile/follow/update' => 'profile#list_follow'
  get '/:profile/unfollow/update' => 'profile#list_unfollow'

  match 'campaign/activate' => 'campaign#activate_campaign'
  get "/campaign/:campaign" => 'campaign#index', :as => :campaign

  match '/campaign/:campaign/complete_blog_task' => 'campaign#complete_blog_task', :as => :campaign
  match '/campaign/:campaign/undo_blog_task' => 'campaign#undo_blog_task', :as => :campaign
  match '/campaign/:campaign/complete_email_task' => 'campaign#complete_email_task', :as => :campaign
  match '/campaign/:campaign/undo_email_task' => 'campaign#undo_email_task', :as => :campaign
  match '/campaign/:campaign/complete_yelp_task' => 'campaign#complete_yelp_task', :as => :campaign
  match '/campaign/:campaign/undo_yelp_task' => 'campaign#undo_yelp_task', :as => :campaign
  match '/campaign/:campaign/complete_facebook_task' => 'campaign#complete_facebook_task', :as => :campaign
  match '/campaign/:campaign/undo_facebook_task' => 'campaign#undo_facebook_task', :as => :campaign
  match '/campaign/:campaign/complete_twitter_task' => 'campaign#complete_twitter_task', :as => :campaign
  match '/campaign/:campaign/undo_twitter_task' => 'campaign#undo_twitter_task', :as => :campaign
  match '/campaign/:campaign/complete_custom_task' => 'campaign#complete_custom_task', :as => :campaign
  match '/campaign/:campaign/undo_custom_task' => 'campaign#undo_custom_task', :as => :campaign
  match '/campaign/:campaign/track_pinterest_click' => 'campaign#track_pinterest_click', :as => :campaign
  match '/campaign/:campaign/track_twitter_click' => 'campaign#track_twitter_click', :as => :campaign
  match '/campaign/:campaign/track_linkedin_click' => 'campaign#track_linkedin_click', :as => :campaign
  match '/campaign/:campaign/track_google_plus_click' => 'campaign#track_google_plus_click', :as => :campaign
  match '/campaign/:campaign/track_facebook_click' => 'campaign#track_facebook_click', :as => :campaign
  match '/campaign/:campaign/tumblr_auth' => 'campaign#tumblr_auth', :as => :campaign
  match '/campaign/:campaign/tumblr_blogs' => 'campaign#tumblr_blogs', :as => :campaign
  match '/campaign/:campaign/tumblr_content' => 'campaign#tumblr_content', :as => :campaign
  match '/campaign/:campaign/tumblr_post' => 'campaign#tumblr_post', :as => :campaign

  match '/campaign/:campaign/go_viral' => 'embed_widgets#website_index', :as => :campaign
  match '/campaign/:campaign/go_viral_joined' => 'embed_widgets#website_joined', :as => :campaign
  match '/campaign/:campaign/go_viral_signup' => 'embed_widgets#website_signup', :as => :campaign
  match '/campaign/:campaign/go_viral_join_camp' => 'embed_widgets#website_join_campaign', :as => :campaign
  match '/campaign/:campaign/go_viral_email_signin' => 'embed_widgets#website_email_signin', :as => :campaign
  match '/campaign/:campaign/go_viral_create_username' => 'embed_widgets#website_create_username', :as => :campaign
  match '/campaign/:campaign/go_viral_update_username' => 'embed_widgets#website_update_username', :as => :campaign
  match '/campaign/:campaign/go_viral_create_account_from_email' => 'embed_widgets#website_create_account_from_email', :as => :campaign
  match '/campaign/:campaign/go_viral_task_complete' => 'embed_widgets#website_task_complete', :as => :campaign
  match '/campaign/:campaign/go_viral_task_undo' => 'embed_widgets#website_task_undo', :as => :campaign
  match '/campaign/:campaign/go_viral_fb_wall_post' => 'embed_widgets#website_fb_wall_post', :as => :campaign
  match '/campaign/:campaign/go_viral_fb_error' => 'embed_widgets#website_fb_error_page', :as => :campaign

  match '/campaign/:campaign/create-raffle-winner' => 'campaign#create_raffle_winner', :as => :campaign

  match '/post/facebook' => 'campaign#facebook_wall_post'
  #match '/facebook/connect' => 'users#facebook_connect'

  get "/s/:share" => 'campaign#share', :as => :share

  match '/tasks/:task/check_engage_left' => 'tasks#check_engage_left', :as => :task
  match '/tasks/:task/check_engage_right' => 'tasks#check_engage_right', :as => :task

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

  get '/fbapp/channel.html' => proc {
  	[
  		200,
  		{
  			'Pragma' => 'public',
  			'Cache-Control' => "max-age=#{1.year.to_i}",
  			'Expires' => 1.year.from_now.to_s(:rfc822),
  			'Content-Type' => 'text/html'
  		},
  		['<script type="text/javascript" src="//connect.facebook.net/en_US/all.js"></script>']
  	]
  }

  resources :reset_passwords, except: [:show]
  

  
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
