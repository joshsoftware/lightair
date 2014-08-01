module Light
  class MyWorker
    include Sidekiq::Worker

    def perform(email)
      news = Newsletter.first
      emailid = User.where(email_id: email)[0]
      UserMailer.welcome_message(emailid.email_id,news.content,emailid.id,emailid.username).deliver
    end
  end
end
