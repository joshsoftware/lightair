module Light
  class HardWorker
    include Sidekiq::Worker
    sidekiq_options queue: :lightair

    def perform(user_ids, newsletter_id, date, status = nil)
      newsletter = Light::Newsletter.where(id: newsletter_id).first
      user_ids.each do |id|
        user = Light::User.where(id: id, :sent_on.nin => [date]).first
        if user.present?
          Light::UserMailer.welcome_message(user.email_id, newsletter, user.token).deliver_now
          sent_on = user.sent_on << date
          if status.present? && status.include?('Opt in')
            user.update_attributes(
              sent_on: sent_on,
              sidekiq_status: status,
              opt_in_mail_sent_at: DateTime.now
            )
          elsif status.present? && status.include?('Opt out')
            user.update_attributes(
              sent_on: sent_on,
              sidekiq_status: 'Subscribed',
              subscribed_at: DateTime.now,
              is_subscribed: true
            )
          else
            user.update_attributes(sent_on: sent_on)
          end
        end
      end
    end
  end
end
