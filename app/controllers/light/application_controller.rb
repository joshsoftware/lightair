class Light::ApplicationController < ApplicationController
  layout 'application'

  before_filter :verified_request?

  def verified_request?
    if params[:controller].eql?('light/users') and params[:action].eql?('opt_in')
      true
    else
      super()
    end
  end
end
