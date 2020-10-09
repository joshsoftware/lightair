$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "light/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "light"
  s.version     = Light::VERSION
  s.authors     = ["Kanhaiya"]
  s.email       = ["kanhaiya@joshsoftware.com"]
  s.homepage    = ""
  s.summary     = "Newsletter Management System"
  s.description = "Ruby on Rails App"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.5.2"
  s.add_dependency 'sass-rails', '~> 4.0.3'
  s.add_dependency 'haml'
  s.add_dependency 'haml-rails'
  s.add_dependency 'uglifier', '>= 1.3.0'
  s.add_dependency 'coffee-rails', '~> 4.0.0'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'turbolinks'
  s.add_dependency 'jbuilder', '~> 2.0'
  s.add_dependency 'spring'
  s.add_dependency 'omniauth-google-oauth2'
  s.add_dependency 'google-api-client'
  s.add_dependency 'google_drive' 
  s.add_dependency 'sendgrid'
  s.add_dependency 'sidekiq'
  s.add_dependency 'mongoid'
  s.add_dependency 'devise_invitable'
  s.add_dependency 'bootstrap-sass'
  s.add_dependency 'bootstrap-datepicker-rails', '1.3.0.2'
  s.add_dependency 'simple_form'
  s.add_dependency 'redactor-rails', '0.4.5'
  s.add_dependency 'carrierwave'
  s.add_dependency 'carrierwave-mongoid'
  s.add_dependency 'mini_magick'
  s.add_dependency 'redis-rails'
  s.add_dependency 'redis-namespace'
  s.add_dependency 'rest-client'
  s.add_dependency 'select2-rails'
  s.add_dependency 'sendgrid_toolkit'
  s.add_dependency 'sendgrid-ruby', '~> 6.2.0'
  s.add_dependency 'mongoid-history'
end
