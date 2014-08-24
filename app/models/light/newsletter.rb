module Light
  class Newsletter
    include Mongoid::Document
      field :subject,     type: String
      field :content,     type: String 
      field :sent_on,     type: Date
      field :users_count,  type: Integer, default: 0

      validates :content, :subject, presence: true

      has_many :users
  end
end
