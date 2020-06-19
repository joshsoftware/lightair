namespace :light do
  desc 'Checking and updating the User status (Subscribed and Unsubscribed)'
  task :update_user_status => :environment do

    print "\n\n Update the flag is_subscribed for status: "
    ['Bounced', 'Spam', 'Opt in mail sent', 'Invalid'].each do |status|
      print "\n #{status} : "
      print Light::User.where(sidekiq_status: status)
                   .update_all(is_subscribed: false)[:n]
      # Keeping is_blocked as is, because we have code sit in there depending on it.
    end

    print "\n\n Fix the data for Blocked Users : "
    print "\n Update flags for Block user : "
    print Light::User.where(sidekiq_status: 'Block')
                 .update_all(is_subscribed: false, is_blocked: true)[:n]

    print "\n Update status for new_users who are blocked : "
    print Light::User.where(is_subscribed: false, sidekiq_status: 'new user', is_blocked: true)
                 .update_all(sidekiq_status: 'Block')[:n]


    print "\n\n Update one who dones't have sidekiq_status : "
    print "\n Unsubscribed : "
    print Light::User.where(is_subscribed: false, sidekiq_status: nil, :is_blocked.in => [false, nil])
                 .update_all(sidekiq_status: 'Unsubscribed', unsubscribed_at: DateTime.now)[:n]

    print "\n Block (is_subscribed: false) : "
    print Light::User.where(is_subscribed: false, is_blocked: true, sidekiq_status: nil)
                 .update_all(sidekiq_status: 'Block')[:n]

    print "\n Block (is_subscribed: true) : "
    print Light::User.where(is_subscribed: true, is_blocked: true, sidekiq_status: nil)
                 .update_all(is_subscribed: false, sidekiq_status: 'Block')[:n]

    print "\n Subscribed : "
    print Light::User.where(is_subscribed: true, sidekiq_status: nil)
                 .update_all(sidekiq_status: 'Subscribed')[:n]

    print "\n\n Updated flag value for is_blocked: nil to flase : "
    print Light::User.where(is_blocked: nil)
                 .update_all(is_blocked: false)[:n]

    print "\n\n Updated Status for Web Subscription Request : "
    print Light::User.where(sidekiq_status: 'web subscription request')
                    .update_all(source: 'web subscription request',
                                is_subscribed: false,
                                sidekiq_status: 'Unsubscribed',
                                unsubscribed_at: DateTime.now)[:n]

    def check_status(status)
      Light::User.where(sidekiq_status: status).count
    end

    # Status wise count of User
    print "\n\n Total no of User Status : " +
         "\n Subscribed : #{check_status('Subscribed')}" +
         "\n Unsubscribed : #{check_status('Unsubscribed')}" +
         "\n New User : #{check_status('new user')}" +
         "\n Invalid : #{check_status('Invalid')}" +
         "\n Spam : #{check_status('Spam')}" +
         "\n Blocked : #{check_status('Block')}" +
         "\n Bounced : #{check_status('Bounced')}" +
         "\n Opt in User: #{check_status('Opt in mail sent')} \n\n"
 end
end

