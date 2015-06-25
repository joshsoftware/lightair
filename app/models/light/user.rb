module Light
  class User
    include Mongoid::Document

    field :email_id,      type: String
    field :username,      type: String
    field :is_subscribed, type: Boolean, default: true
    field :joined_on,     type: Date
    field :source,        type: String
    field :sent_on,       type: Array, default: []
    field :sidekiq_status

    validates :email_id, presence: true
    validates_format_of :email_id, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/i, on: :create
    validates :username, presence: true
    validates :email_id, uniqueness: true

    scope :subscribed_users, -> { where is_subscribed: true}

    def self.add_users_from_worksheet(worksheet, column = 1)
      fails = []

      worksheet.rows.count.times do |i|
        user = new(
          email_id:       worksheet[i + 1, column],
          username:       worksheet[i + 1, column - 1],
          is_subscribed:  true,
          joined_on:      Date.today,
          source:         'Google Spreadsheet')

        if user.save
        else
          fails << worksheet[i + 1, column]
        end
      end
      fails.delete_at(0)
      fails
    end

    def self.import(file)
      return {error: "Please select file"} unless file
      rows = CSV.read(file.path)
      header = rows.delete_at(0)
      return {error: "Header doesn't matches"} if header != ['Full Name', 'Email']
      ImportWorker.perform_async(rows)
      {success: 'You will get an update email.'}
    end

  end
end
