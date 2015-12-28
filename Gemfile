source "https://rubygems.org"

# Declare your gem's dependencies in light.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec
ruby '2.2.4'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'

# Use google_drive to read/write files or spreadsheets from google drive
gem 'omniauth-google-oauth2'
gem 'google-api-client', require: 'google/api_client' 
gem 'google_drive', git: 'git://github.com/SixiS/google-drive-ruby'

# Use sendrid to access sendgrid api to send mails and get their status
gem 'sendgrid'

# Use mongoid to utilise mongodb
gem 'mongoid'

# The following gems for testing purpose in development and testing environment
group :development, :test do
  # Rspec is used to write the test cases
  gem 'rspec-rails'
  # Use factory girl to pass random data for test cases
  gem 'factory_girl_rails'
  # Use faker to generate fake strings and data
  gem 'faker'
  # Use to clean database after executing a test case
  gem 'database_cleaner'
  # Use to track how much code has been tested
  gem 'simplecov', '~> 0.7.1'
end

group :test do
  # Webmock to stub http requests
  gem 'webmock'
  # VCR to record the responses from web and replay them when needed
  gem 'vcr'
end

gem 'simple_form'
# Use to add redactor editor
gem 'redactor-rails'
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'mini_magick'
gem 'redis-rails'
gem 'redis-namespace'
gem 'mina'
gem 'mina_extensions'
gem 'rest_client'
gem 'pry'
gem 'select2-rails'
gem 'sinatra', '>=1.3.0', :require => nil
gem 'therubyracer'
gem 'sendgrid_toolkit'
gem 'mongoid_slug'
# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
gem "mongoid-paperclip", :require => "mongoid_paperclip"
gem 'imgkit'


