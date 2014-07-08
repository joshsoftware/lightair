Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_KEY'],
  {
    name:                 "google",
    scope:                'userinfo.profile,userinfo.email,drive,https://spreadsheets.google.com/feeds',
    prompt:               'consent',
    access_type:          "offline",
  }

  #provider :linkedin, '75cmlzl0cpmwa2', 'I5y0aRBkfpgMmTqp', redirect_uri: 'http://localhost:8080/auth/linkedin/callback', scope:'r_emailaddress r_network r_contactinfo rw_company_admin rw_nus rw_groups w_messages r_basicprofile r_fullprofile'
end