module Light

  class UserMailer < ActionMailer::Base
    include SendGrid
    sendgrid_category :use_subject_lines
    sendgrid_enable   :ganalytics, :opentrack
    sendgrid_unique_args :key1 => "value1", :key2 => "value2"

    def welcome_message(email, newsletter_content,id,name)
      sendgrid_category "Welcome"
      sendgrid_unique_args :key2 => "newvalue2", :key3 => "value3"

      content = ERB.new(newsletter_content)
      object_id = id
      #headers['X-SMTPAPI'] = { :to => user.pluck(:email_id) }.to_json

      mail( to: email,
          category: "newuser",
          subject: "Welcome #{name}",
          body: content.result(binding),
          content_type: "text/html" 
        )
    end
  end
end
