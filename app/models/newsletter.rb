class Newsletter
  include Mongoid::Document
    field :content,     type: String 
    field :sent_on,     type: Date
    field :users_count,  type: Integer, default: 0

    validates :content, presence: true
    validates :sent_on, presence: true

    has_many :users

end
