require 'mongoid'
require 'carrierwave/mongoid'
require 'haml-rails'
require 'bootstrap-datepicker-rails'
require 'uglifier'
require 'jquery-rails'
require 'turbolinks'
require 'jbuilder'
require 'omniauth-google-oauth2'
require 'google_drive'
require 'sendgrid'
require 'bootstrap-sass'
require 'bootstrap-datepicker-rails'
require 'simple_form'
require 'redactor-rails'
require 'carrierwave'
require 'mini_magick'
require 'redis-namespace'
require 'select2-rails'



module Light
  class Engine < ::Rails::Engine
    isolate_namespace Light

    config.generators do |g|
      g.template_engine :haml
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

  end
end
