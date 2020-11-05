module Light
  class OptOutWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(newsletter_id)
      date = Date.today.strftime("%Y%m")
      users = Light::User.users_for_opt_out_mail
      number_of_opt_out_users = users.count
      number_of_opt_out_users_count = number_of_opt_out_users
      current_batch = 0
      users_in_batch = 250
      newsletter = Light::Newsletter.where(id: newsletter_id).first
      if newsletter
        while number_of_opt_out_users > 0
          user_ids = users.limit(users_in_batch).skip(users_in_batch*current_batch).collect { |user| user.id.to_s }
          current_batch += 1
          number_of_opt_out_users -= users_in_batch
          Light::HardWorker.perform_async(user_ids, newsletter.id.to_s, date, 'Opt out mail sent')
        end
        opt_out_count = newsletter.users_count + number_of_opt_out_users_count
        newsletter.update_attribute(:users_count, opt_out_count)
      else
        logger.info = 'No newsletter present'
      end
    end
  end
end
