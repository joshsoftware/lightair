class HardWorker
  include Sidekiq::Worker

  def perform()
    @users = User.where(is_subscribed: "true")
    @news = Newsletter.last
    @users.each do |a|
      UserMailer.welcome_message(a.email_id,@news.content,a.id,a.username).deliver
    end

  end
end

