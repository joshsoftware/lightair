module Light
  class UserWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform
      date = Date.today.strftime("%Y%m")
      number_of_subscribed_users = Light::User.where(sidekiq_status: 'Subscribed', :sent_on.nin => [date],  is_blocked: {"$ne" => true}).count
      #number_of_subscribed_users = Light::User.users_for_opt_in_mail.count
      number_of_subscribed_users_count = number_of_subscribed_users
      current_batch = 0
      users_in_batch = 250
      newsletter = Light::Newsletter.where(newsletter_type: Light::Newsletter::VALID_NEWSLETTER_TYPES[:MONTHLY]).
        order_by([:sent_on, :desc]).first

      #newsletter = Light::Newsletter.where(newsletter_type: Light::Newsletter::VALID_NEWSLETTER_TYPES[:OPT_IN]).
      #  order_by([:sent_on, :desc]).first
      if newsletter
        while number_of_subscribed_users > 0
          user_ids = Light::User.where(sidekiq_status: 'Subscribed', :sent_on.nin => [date] , is_blocked: {"$ne" => true}).order_by([:email_id, :asc]).limit(users_in_batch).skip(users_in_batch*current_batch).collect { |user| user.id.to_s }
          #user_ids  = Light::User.users_for_opt_in_mail.order_by([:email_id, :asc]).limit(users_in_batch).skip(users_in_batch*current_batch).collect { |user| user.id.to_s }
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

