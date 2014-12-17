module Light
  class UserWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform
      date = Date.today.strftime("%Y%m")
      number_of_subscribed_users = Light::User.where(is_subscribed: true, :sent_on.nin => [date]).count
      number_of_subscribed_users_count = number_of_subscribed_users
      current_batch = 0
      users_in_batch = 250
      newsletter = Light::Newsletter.order_by([:sent_on, :desc]).first
      if newsletter
        while number_of_subscribed_users > 0
          user_ids = Light::User.where(is_subscribed: true, :sent_on.nin => [date]).order_by([:email_id, :asc]).limit(users_in_batch).skip(users_in_batch*current_batch).collect { |user| user.id.to_s }
          current_batch += 1
          number_of_subscribed_users -= users_in_batch
          Light::HardWorker.perform_async(user_ids, newsletter.id.to_s, date)
        end
        newsletter.update_attribute(:users_count, number_of_subscribed_users_count)
      else
        logger.info = "No newsletter present"
      end
    end
  end
end

