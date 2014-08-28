module Light
  class HardWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform
      date = Date.today.strftime("%Y%m")
      users = Light::User.where(is_subscribed: true, :sent_on.nin => [date]).order_by([:email_id, :asc])
      newsletter = Light::Newsletter.order_by([:sent_on, :desc]).first
      users.each do |user|
        if newsletter 
          Light::UserMailer.welcome_message(user.email_id, newsletter).deliver
          user.update_attribute :sent_on, user.sent_on << date
        else
          logger.info "No NewsLetter present"
        end
      end
    end
  end
end
