class HardWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :lightair

  def perform()
    #if check then
    date = Date.today.strftime("%Y%m")
    users = User.where(is_subscribed: "true", :sent_on.nin => [date]).order_by([:email_id, :asc])
    news = Newsletter.order_by([:sent_on, :desc]).first
    users.each do |a|
      UserMailer.welcome_message(a.email_id, news.content, a.id, a.username).deliver
      a.sent_on << date
      a.save
    end
  end
end

