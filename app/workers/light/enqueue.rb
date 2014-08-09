module Light
  class Enqueue
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair
  
    def perform(email)
      date = Date.today.strftime("%Y%m")
      users = Light::User.where(:email_id.in => email, is_subscribed: true)#, :sent_on.nin => [date]).order_by([:email_id, :asc])
      news = Newsletter.order_by([:sent_on, :desc]).first
      logger.debug users.count
      users.each do |a|
        Light::UserMailer.welcome_message(a.email_id, news.content, a.id, a.username).deliver
        a.sent_on << date
        a.save
      end

      users = Light::User.where(:email_id.in => email, is_subscribed: 'true', :sent_on.in => [date]).order_by([:email_id, :asc])
      users.each do |a|
        a.sent_on.pop
        a.save
      
      end
    end
  end
end

