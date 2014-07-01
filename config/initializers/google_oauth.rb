Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_KEY'],
  {
    name:                 "google",
    scope:                "userinfo.profile,userinfo.email,drive,https://spreadsheets.google.com/feeds",
    prompt:               "consent",
    access_type:          "offline",
  }
end