module Light
  class HardWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(user_ids, newsletter_id, date)
      newsletter = Light::Newsletter.where(id: newsletter_id).first
      user_ids.each do |id| 
        user = Light::User.where(id: id).first
        Light::UserMailer.welcome_message(user.email_id, newsletter, user.id).deliver
        user.update_attribute :sent_on, user.sent_on << date
      end
    end
  end
end
