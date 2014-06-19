class User
  include Mongoid::Document
  
  field :email,        type: String
  field :subscription, type: Integer
  field :sent,         type: Integer
  field :joining_date  type: Date
  field :leaving_date  type: Date
  field :source        type: String

  belongs_to :admin
end
