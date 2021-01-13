require 'devise'

module Light
  class User
    include Mongoid::Document
    include Mongoid::Slug
    include Mongoid::History::Trackable

    NEW_USER = 'new user'

    field :email_id,      type: String
    field :username,      type: String
    field :is_subscribed, type: Boolean, default: false
    field :joined_on,     type: Date
    field :source,        type: String
    field :sent_on,       type: Array, default: []
    field :sidekiq_status
    field :token
    field :opt_in_mail_sent_at, type: DateTime
    field :subscribed_at, type: DateTime
    field :unsubscribed_at, type: DateTime
    field :remote_ip
    field :user_agent, type: String
    field :is_blocked, type: Boolean, default: false

    validates :email_id, presence: true
    validates_format_of :email_id, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/i, on: :create
    validates :username, presence: true
    validates :email_id, uniqueness: true

    slug :username

    track_history on: [:opt_in_mail_sent_at, :subscribed_at, :remote_ip,
                       :user_agent, :is_subscribed, :unsubscribed_at]
    before_create do
      self.joined_on = Date.today
      self.sidekiq_status = NEW_USER if self.sidekiq_status.blank?
      self.token = Devise.friendly_token
      while User.where(token: self.token).present?
        self.token = Devise.friendly_token
      end
    end

    scope :subscribed_users, -> { where(is_subscribed: true, sidekiq_status: 'Subscribed') }
    scope :unsubscribed_users, -> { where(is_subscribed: false, sidekiq_status: 'Unsubscribed') }
    scope :new_users, -> { where(is_subscribed: false, sidekiq_status: NEW_USER) }
    scope :blocked_users, -> { where(is_subscribed: false, sidekiq_status: 'Block') }
    scope :bounced_users, -> { where(is_subscribed: false, sidekiq_status: 'Bounced') }
    scope :spam_users, -> { where(is_subscribed: false, sidekiq_status: 'Spam') }
    scope :invalid_users, -> { where(is_subscribed: false, sidekiq_status: 'Invalid') }
    scope :opt_in_users, -> { where(is_subscribed: false, sidekiq_status: 'Opt in mail sent') }

    def self.add_users_from_worksheet(worksheet, column = 1)
      fails = []

      worksheet.rows.count.times do |i|
        user = new(
          email_id:       worksheet[i + 1, column],
          username:       worksheet[i + 1, column - 1],
          is_subscribed:  true,
          joined_on:      Date.today,
          source:         'Google Spreadsheet'
        )

        if user.save
        else
          fails << worksheet[i + 1, column]
        end
      end
      fails.delete_at(0)
      fails
    end

    def self.import(file, email='')
      return {error: 'Please select CSV file'} if (file.blank? or file.content_type != 'text/csv')
      file = CSV.open(file.path, :row_sep => :auto, :col_sep => ',')
      rows = file.read
      header = rows.delete_at(0)
      if header.first.strip.downcase != 'full name' and header[1].strip.downcase != 'email'
        return {error: "Header doesn't matches"}
      end
      ImportWorker.perform_async(rows, email)
      {success: 'You will get an update email.'}
    end

    def self.get_new_users
      date = Date.today.strftime('%Y%m')
      self.new_users.where(:sent_on.nin => [date], is_blocked: false).order_by([:email_id, :asc])
    end
  end
end
