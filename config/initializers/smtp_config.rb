if Rails.env.development? || Rails.env.staging?
  class OverrideMailRecipient
    def self.delivering_email(message)
      message.subject = "#{message.to} #{message.subject}"
      message.to = 'swapnil@joshsoftware.com'
    end
  end
  ActionMailer::Base.register_interceptor(OverrideMailRecipient)
end
