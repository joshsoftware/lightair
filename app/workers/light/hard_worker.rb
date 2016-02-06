module Light
  class HardWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(user_ids, newsletter_id, date, status = nil)
      newsletter = Light::Newsletter.where(id: newsletter_id).first
      user_ids.each do |id| 
        user = Light::User.where(id: id, :sent_on.nin => [date]).first
        if user.present?
          Light::UserMailer.welcome_message(user.email_id, newsletter, user.slug).deliver
          sent_on = user.sent_on << date
          user.update_attributes(sent_on: sent_on, sidekiq_status: status)
        end
      end
    end
  end
end
