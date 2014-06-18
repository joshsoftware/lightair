class Admin
  include Mongoid::Document

  field :email_id,    type: String
  field :password,    type: String

  has_many :users
  has_many :news_letters  
end
