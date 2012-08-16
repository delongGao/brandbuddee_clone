Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :facebook, '380121918698790', '319f251fc875dde2c3f5fd44b7fbd8da'
  #provider :facebook, '380121918698790', '319f251fc875dde2c3f5fd44b7fbd8da', :scope => 'email,offline_access'#, :display => 'popup'
  provider :twitter, 'a8uYjTwOukqYxm9S97Xk1g', 'wtn6WvMp56C6glHzXJd2aEmC2zzG50PdMJAycdt1Xs'
  provider :facebook, '146239612181043', '1f8dd73e2b62cdebec483bcfd2b7612e', {:scope => 'email,offline_access,publish_actions,publish_stream,user_birthday,user_about_me,user_location,user_likes,user_education_history,user_website,read_friendlists,user_interests,user_hometown,user_status'} if Rails.env.development?
  provider :facebook, '236502566402197', '452c1016a2216d806889206fc269490d', {:scope => 'email,offline_access'} if Rails.env.production?
end