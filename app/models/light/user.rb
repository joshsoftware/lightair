module Light
  class User
    include Mongoid::Document
    include Mongoid::Slug

    NEW_USER = "new user"

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

    slug :username

    before_create do
      self.joined_on = Date.today
    end

    scope :subscribed_users, -> { where is_subscribed: true}
    scope :new_users, -> { where(is_subscribed: false, sidekiq_status: NEW_USER)}

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

    def self.import(file, email='')
      return {error: "Please select CSV file"} if (file.blank? or file.content_type != 'text/csv')
      file = CSV.open(file.path, :row_sep => :auto, :col_sep => ",")
      rows = file.read
      header = rows.delete_at(0)
      return {error: "Header doesn't matches"} if header != ['Full Name', 'Email']
      ImportWorker.perform_async(rows, email)
      {success: 'You will get an update email.'}
    end

    def self.users_for_opt_in_mail
      date = Date.today.strftime("%Y%m")
      self.new_users.where(:sent_on.nin => [date]).order_by([:email_id, :asc])
    end
  end
end
