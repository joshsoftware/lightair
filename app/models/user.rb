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

end
