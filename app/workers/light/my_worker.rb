module Light
  class MyWorker
    include Sidekiq::Worker

    def perform(email)
      news = Light::Newsletter.first
      emailid = Light::User.where(email_id: email)[0]
      Light::UserMailer.welcome_message(emailid.email_id,news.content,emailid.id,emailid.username).deliver
    end
  end
end
