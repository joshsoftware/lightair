class HardWorker
  include Sidekiq::Worker

  def perform(check,users)
    if check then
      #@users = User.where(is_subscribed: "true")
      news = Newsletter.first
      users.each do |a|
        UserMailer.welcome_message(a.email_id, news.content, a.id, a.username).deliver
      end
    else
      #@emails = params[:email][:email_id]
      news = Newsletter.first
      email = users.split(",")
      email.each do |p|
        emailid = User.where(email_id: p)[0]
        UserMailer.welcome_message(emailid['email_id'], news.content, emailid.id, emailid.username).deliver
      end
    end
  end
end

