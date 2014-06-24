class Newsletter
  include Mongoid::Document
    field :content,     type: String 
    field :sent_on,     type: Date
    field :user_count,  type: Integer

    validates :content, presence: true
    validates :sent_on, presence: true
    validates :user_count, presence: true
    validates :user_count, uniqueness: true

    has_many :users
end
