module Light
  class Enqueue
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(email)
      date = Date.today.strftime("%Y%m")
      news = Light::Newsletter.where(newsletter_type: Light::Newsletter::NEWSLETTER_TYPES[:MONTHLY]).
        order_by([:sent_on, :desc]).first
      Light::UserMailer.welcome_message(email, news, 'test_user_dummy_id').deliver_now if news
    end
  end
end
