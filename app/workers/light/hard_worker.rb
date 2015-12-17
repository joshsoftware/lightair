module Light
  class HardWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(user_ids, newsletter_id, date)
      newsletter = Light::Newsletter.where(id: newsletter_id).first
      user_ids.each do |id| 
        user = Light::User.where(id: id, is_subscribed: true, :sent_on.nin => [date]).first
        if user.present?
          Light::UserMailer.welcome_message(user.email_id, newsletter, user.slug).deliver
          user.update_attribute :sent_on, user.sent_on << date
        end
      end
    end
  end
end
