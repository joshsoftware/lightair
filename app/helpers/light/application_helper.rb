module Light
  module ApplicationHelper
    def is_newsletter_controller?
      params[:controller] == 'light/newsletters'
    end

    def is_opt_out_action?
      params[:action].in?(['opt_out', 'show'])
    end

    def is_not_opt_out_newsletter?
      (is_newsletter_controller? && !is_opt_out_action?)|| (
          @newsletter.present? && 
          !@newsletter.opt_out?
        ) || !is_newsletter_controller?
    end
  end
end
