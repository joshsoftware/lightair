namespace :light do
  desc 'Checking and updating the User status (Subscribed and Unsubscribed)'
  task :update_user_status => :environment do
    
    # setting status to Unsubscribed for users whose flag 'is_subscribed' is false
    # and status is nil 
    Light::User.where(is_subscribed: false, sidekiq_status: nil)
               .update_all(sidekiq_status: 'Unsubscribed')

    # setting status to Subscribed for users whose flag 'is_subscribed' is true
    # and status is nil
    Light::User.where(is_subscribed: true, sidekiq_status: nil)
               .update_all(sidekiq_status: 'Subscribed')

    # change 'web subscription request' status to 'Unsubscribed'
    # 1. add previous status into source field
    web_subscription = Light::User.where(sidekiq_status: 'web subscription request')
    web_subscription.update_all(source: 'web subscription request')

    # 2. change status to 'Unsubscribed'
    web_subscription.update_all(sidekiq_status: 'Unsubscribed')


    # Fix flag 'is_subscribed' for Blocked Users
    Light::User.where(is_subscribed: true, sidekiq_status: 'Block')
               .update_all(is_subscribed: false)
    
    def check_status(status)
      Light::User.where(sidekiq_status: status).count
    end

    # Status wise count of User
    puts 'Total no of User Status : ' +
         "\n Subscribed : #{check_status('Subscribed')}" +
         "\n Unsubscribed : #{check_status('Unsubscribed')}" +
         "\n New User : #{check_status('Invalid')}" +
         "\n Invalid : #{check_status('new user')}" +
         "\n Spam : #{check_status('Spam')}" +
         "\n Blocked : #{check_status('Block')}" +
         "\n Bounced : #{check_status('Bounced')}" +
         "\n Opt in User: #{check_status('Opt in mail sent')}"
 end
end

