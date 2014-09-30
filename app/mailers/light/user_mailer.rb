module Light

  class UserMailer < ActionMailer::Base
    include SendGrid
    sendgrid_category :use_subject_lines
    sendgrid_enable   :ganalytics, :opentrack
    sendgrid_unique_args :key1 => "value1", :key2 => "value2"

    def welcome_message(email, newsletter, user_id)
      sendgrid_category "Welcome"
      sendgrid_unique_args :key2 => "newvalue2", :key3 => "value3"

      @user_id = user_id
      content = ERB.new(CGI.unescapeHTML(newsletter.content))
      #headers['X-SMTPAPI'] = { :to => user.pluck(:email_id) }.to_json

      mail(to: email, category: "newuser", subject: newsletter.subject,
           body: content.result(binding),
           content_type: "text/html")
    end
  end
end
