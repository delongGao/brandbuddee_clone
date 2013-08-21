Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :facebook, '380121918698790', '319f251fc875dde2c3f5fd44b7fbd8da'
  #provider :facebook, '380121918698790', '319f251fc875dde2c3f5fd44b7fbd8da', :scope => 'email,offline_access'#, :display => 'popup'
  provider :twitter, 'XS3ZFcP3lxmz7WFssNcF8Q', 'HHd6Pr333lDBkOcoW6FXteoBCGxUiM9gwcMl3GYccE'
  provider :facebook, '253857021420655', 'ac29289c15bff7d445bb51e8f1646ada', {:scope => 'email,offline_access,publish_actions,publish_stream,user_birthday,user_about_me,user_location,user_likes,user_education_history,user_website,read_friendlists,user_interests,user_hometown,user_status,manage_pages'} if Rails.env.development?
  provider :facebook, '278238152312772', 'fbf139910f26420742f3d88f3b25f9a9', {:scope => 'email,offline_access,publish_actions,publish_stream,user_birthday,user_about_me,user_location,user_likes,user_education_history,user_website,read_friendlists,user_interests,user_hometown,user_status,manage_pages'} if Rails.env.production?
  provider :tumblr, 'FdB7CU7UBPtvVULdOzWjcz0oGThl10jPQdQb2j89GbBgRBjFZY', 'j2R5FJnIoDjtjQXFZULSdb6hYkH4Ur5b84IQZrLAxsoFdOvdND' if Rails.env.development?
	provider :tumblr, 'n0UjPDfQllFWOqYvxudHIez5nc4cMTmLeoFabJXn0VvBIYqM8E', 'xbjErcTpXvfnrHpuUM1rHNY7VcqBMAdv5GIXcRHNYYh5wDhnZU' if Rails.env.production?
	OmniAuth.config.on_failure = SessionsController.action(:failure)
end