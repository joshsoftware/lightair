class User
  include Mongoid::Document

  field :email_id,      type: String
  field :is_subscribed, type: Boolean
  field :joined_on,     type: Date
  field :source,        type: String

  validates :email_id, presence: true
  validates :is_subscribed, presence: true
  validates :joined_on, presence: true
  validates :source, presence: true
  validates :email_id, uniqueness: true

  belongs_to :newsletter, counter_cache: :users_count

  def self.add_users_from_worksheet(worksheet, column = 1)
    worksheet.rows.count.times do |i|
      User.create(email_id:       worksheet[i + 1, column],
                  is_subscribed:  true,
                  joined_on:      Date.today,
                  source:         'Google Spreadsheet')
    end
  end
end
