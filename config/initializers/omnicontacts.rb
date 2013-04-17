require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, "163509294061.apps.googleusercontent.com", "LQVxAp3Qx1-_IcoDvipJnE2l", {:redirect_path => "/invite/gmail"}
  importer :yahoo, "dj0yJmk9OFFxcE10ZTdJWU1SJmQ9WVdrOVVVOWllRlJUTkhNbWNHbzlNVFkwTlRnMU1USTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD05NA--", "8d88ccd10c9c4d8b923867ce4eec8d500a06a5ce", {:callback_path => '/invite/yahoo'}
  importer :hotmail, "00000000480F052F", "O-FrNf4vme9xgUhgpIlv0adhdi5DcOVp", {:redirect_path => "invite/hotmail"}
end