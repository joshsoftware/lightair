module Light
  class UserWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(template_type)
      newsletter = Light::Newsletter.where(
        newsletter_type: Light::Newsletter::VALID_NEWSLETTER_TYPES[:MONTHLY]
      ).order_by([:sent_on, :desc]).first

      if template_type == 'Newsletter' && newsletter
        send_monthly_mails(newsletter, template_type)
      elsif template_type == 'Sendgrid'
        newsletter = Light::Newsletter.new(
          newsletter_type: Light::Newsletter::VALID_NEWSLETTER_TYPES[:MONTHLY],
          subject: "Josh Software | Newsletter | #{Date.today.strftime("%B %Y")}",
          sent_via_sendgrid_api: true
        )
        newsletter.save(validate: false)
        send_monthly_mails(newsletter, template_type)
      else
        logger.info = "No newsletter present"
      end
    end

    def send_monthly_mails(newsletter, template_type)
      date = Date.today.strftime("%Y%m")
      number_of_subscribed_users = Light::User.where(
        is_subscribed: true,
        :sent_on.nin => [date],
        is_blocked: {"$ne" => true}
      ).count
      
      number_of_subscribed_users_count = number_of_subscribed_users
      current_batch = 0
      users_in_batch = 250

      while number_of_subscribed_users > 0
        user_ids = Light::User.where(
          is_subscribed: true,
          :sent_on.nin => [date],
          is_blocked: {"$ne" => true}
        ).order_by([:email_id, :asc])
         .limit(users_in_batch)
         .skip(users_in_batch*current_batch)
         .collect { |user| user.id.to_s }

        current_batch += 1
        number_of_subscribed_users -= users_in_batch
        Light::HardWorker.perform_async(template_type, user_ids, newsletter.id.to_s, date)
      end
      newsletter.set(users_count: number_of_subscribed_users_count)
    end
  end
end

