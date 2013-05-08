Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :facebook, '380121918698790', '319f251fc875dde2c3f5fd44b7fbd8da'
  #provider :facebook, '380121918698790', '319f251fc875dde2c3f5fd44b7fbd8da', :scope => 'email,offline_access'#, :display => 'popup'
  provider :twitter, 'a8uYjTwOukqYxm9S97Xk1g', 'wtn6WvMp56C6glHzXJd2aEmC2zzG50PdMJAycdt1Xs'
  provider :facebook, '343588415732330', '8355ede143963a61b624d82ff354dc08', {:scope => 'email,offline_access,publish_actions,publish_stream,user_birthday,user_about_me,user_location,user_likes,user_education_history,user_website,read_friendlists,user_interests,user_hometown,user_status'} if Rails.env.development?
  provider :facebook, '278238152312772', 'fbf139910f26420742f3d88f3b25f9a9', {:scope => 'email,offline_access,publish_actions,publish_stream,user_birthday,user_about_me,user_location,user_likes,user_education_history,user_website,read_friendlists,user_interests,user_hometown,user_status'} if Rails.env.production?
end