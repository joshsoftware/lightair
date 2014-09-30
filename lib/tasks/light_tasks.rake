# desc "Explaining what the task does"
# task :light do
#   # Task goes here
# end
#
namespace :light do

  task :remove_bounced_emails => :environment do
    bounces = SendgridToolkit::Bounces.new(ENV['NEWSLETTER_SENDGRID_USERNAME'], ENV['NEWSLETTER_SENDGRID_PASSWORD'])
    date = Light::Newsletter.last.sent_on.strftime("%Y-%m-%d")
    bounce_emails = bounces.retrieve :start_date =>  date, :end_date => date
    bounce_emails = bounce_emails.parsed_response.map{|response| response['email']}
    Light::User.where(:email_id.in => bounce_emails).update_all(is_subscribed: false, is_bounced: true)
  end

end

