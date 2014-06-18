class NewsLetter
  include Mongoid::Document

  field :letter,       type: String
  field :letter_date,  type: Date
  field :user_count,   type: Integer

  belongs_to :admin
end
