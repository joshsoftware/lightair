module Light
  class ImportWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :lightair

    def perform(rows, source = "Business Card")
      rows.each do |row|
        email = row[1]
        User.create(username: (row[0] || email), email_id: email, source: source)
      end
    end
  end
end
