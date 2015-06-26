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
      @newsletter_id = newsletter.slug
      content = ERB.new(CGI.unescapeHTML(newsletter.content))
      #headers['X-SMTPAPI'] = { :to => user.pluck(:email_id) }.to_json

      mail(to: email, category: "newuser", subject: newsletter.subject,
           body: content.result(binding),
           content_type: "text/html")
    end

    def import_contacts_update(email, file_path)
      attachments["failed_user_list.csv"] = File.read(file_path)
      email = email || 'test@lightair.com'
      mail(to: email, subject: 'Imported contacts for newsletter.',
           body: 'Imported contacts successfully. Please find attachment for failed users.')
    end
  end
end
