# desc "Explaining what the task does"
# task :light do
#   # Task goes here
# end
#
namespace :light do

  task :remove_bounced_emails => :environment do
    
    bounces = SendgridToolkit::Bounces.new(ENV['NEWSLETTER_SENDGRID_USERNAME'], ENV['NEWSLETTER_SENDGRID_PASSWORD'])
    invalid = SendgridToolkit::InvalidEmails.new(ENV['NEWSLETTER_SENDGRID_USERNAME'], ENV['NEWSLETTER_SENDGRID_PASSWORD'])
    spam = SendgridToolkit::SpamReports.new(ENV['NEWSLETTER_SENDGRID_USERNAME'], ENV['NEWSLETTER_SENDGRID_PASSWORD'])
    blocks = SendgridToolkit::Blocks.new(ENV['NEWSLETTER_SENDGRID_USERNAME'], ENV['NEWSLETTER_SENDGRID_PASSWORD'])
    
    bounce_emails = bounces.retrieve.parsed_response.map{|response| response['email']}
    invalid_emails = invalid.retrieve.parsed_response.map{|response| response['email']}
    spam_emails = spam.retrieve.parsed_response.map{|response| response['email']}
    block_emails = blocks.retrieve.parsed_response.map{|response| response['email']}
    
    #unsubscribe users from our database
    puts bounce_emails.count
    puts invalid_emails.count
    puts block_emails.count
    puts spam_emails.count

    Light::User.where(:email_id.in => bounce_emails).update_all(is_subscribed: false, sidekiq_status: 'Bounced')
    Light::User.where(:email_id.in => invalid_emails).update_all(is_subscribed: false, sidekiq_status: 'Invalid')
    Light::User.where(:email_id.in => spam_emails).update_all(is_subscribed: false, sidekiq_status: 'Spam')
    Light::User.where(:email_id.in => block_emails).update_all(is_subscribed: false, sidekiq_status: 'Block')
    #clean sendgrid... 
    bounces.delete(delete_all: 1)
    invalid.delete(delete_all: 1)
    spam.delete(delete_all: 1)
    blocks.delete(delete_all: 1)
 end

end

