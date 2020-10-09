module Light
  class OptInWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(template_type, newsletter_id=nil)
      newsletter = Light::Newsletter.where(id: newsletter_id).first
      
      if template_type == 'Newsletter' && newsletter
        send_opt_in_mail(newsletter, template_type)
      elsif template_type == 'Sendgrid'
        newsletter = Light::Newsletter.new(
          newsletter_type: Light::Newsletter::VALID_NEWSLETTER_TYPES[:OPT_IN],
          subject: "Josh Software | Newsletter | #{Date.today.strftime("%B %Y")}",
          sent_via_sendgrid_api: true
        )
        newsletter.save(validate: false)
        send_opt_in_mail(newsletter, template_type)
      else
        logger.info = "No newsletter present"
      end
    end

    def send_opt_in_mail(newsletter, template_type)
      date = Date.today.strftime("%Y%m")
      users = Light::User.users_for_opt_in_mail
      number_of_opt_in_users = users.count
      number_of_opt_in_users_count = number_of_opt_in_users
      current_batch = 0
      users_in_batch = 250

      while number_of_opt_in_users > 0
        user_ids = users.limit(users_in_batch).skip(users_in_batch*current_batch).collect { |user| user.id.to_s }
        current_batch += 1
        number_of_opt_in_users -= users_in_batch
        Light::HardWorker.perform_async(template_type, user_ids, newsletter.id.to_s, date, "Opt in mail sent")
      end
      opt_in_count = newsletter.users_count + number_of_opt_in_users_count
      newsletter.set(users_count: opt_in_count)
    end
  end
end

