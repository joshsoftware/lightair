module Light
  class ImportWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(rows, email_id, source = "Business Card")
      file_path = "#{Rails.root.to_s}/tmp/import_contacts_#{Time.now.to_i}.csv"
      CSV.open(file_path, "wb") do |csv| #creates a tempfile csv
        csv << ['Total number of users in the database', Light::User.count]
        csv << ['Total number of rows in uploaded CSV (including blank)', rows.count]
        csv << ["Email", "Name", "Error"] 
        rows.each do |row|
          email = "#{row[1]}"
          name = "#{row[0] || row[1]}"
          user = Light::User.create(username: name, email_id: email, source: source,
                                    sidekiq_status: Light::User::NEW_USER) if email.present? or name.present?
          csv << [email, row[0], user.errors.messages] if user.present? and user.errors.present?
        end
        UserMailer.import_contacts_update(email_id, file_path).deliver
      end
    end
  end
end
