module Light
  class SendgridMailer
    require 'sendgrid-ruby'
    include SendGrid

    TEMPLATES = {
      newsletter_id: ENV['NEWSLETTER_ID']
    }

    def self.mail_to(user=nil)
      if Rails.env.production?
        user.email
      else
        ENV['NEWSLETTER_DEFAULT_EMAILS']
      end
    end

    def self.send(user, extra_params = {})
      to = SendgridMailer.mail_to(user)
      substitutions = SendgridMailer.substitutions_for(user)
      template_id = TEMPLATES[:newsletter_id]
      SendgridMailer.send_mail(to, substitutions, template_id)
    end

    def self.send_mail(to, substitutions, template_id)
      data = {
        'personalizations': [
          {
            'to': [
              {
                'email': to
              }
            ],
            'dynamic_template_data': substitutions
          }
        ],
        'from': {
          'email': 'no-reply@joshsoftware.com'
        },
        'template_id': template_id
      }
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      begin
        response = sg.client.mail._('send').post(request_body: data)
        return response.status_code
      rescue Exception => e
        puts 'Error in sending newsletter email...'
        puts e.inspect
        Rollbar.critical(e, e.message, {
          email_to: to,
          template_id: template_id,
          substitutions: substitutions,
          backtrace: e.backtrace
        })
        return '500'
      end
    end

    def self.substitutions_for(user, extra_params: {})
      {
        unsubscribeURL: unsubscribe_url + "/unsubscribe?token=#{user.token}"
      }.merge(extra_params)
    end

    def self.unsubscribe_url
      'https://' + ActionMailer::Base.default_url_options[:host] 
    end
  end
end
