Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_KEY'],
  {
    name:                 'google',
    scope:                'userinfo.profile,userinfo.email,drive,https://spreadsheets.google.com/feeds',
    prompt:               'consent',
    access_type:          'offline'
  }
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

common_settings = {
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

Light::UserMailer.smtp_settings = common_settings.merge({
  :user_name => ENV['NEWSLETTER_SENDGRID_USERNAME'],
  :password => ENV['NEWSLETTER_SENDGRID_PASSWORD'],
  :address => "smtp.sendgrid.net",
})
