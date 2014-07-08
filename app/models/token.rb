class Token
  include Mongoid::Document

  field :spreadsheet_id, type: String
  field :refresh_token,  type: String
  field :expires_at,     type: Time
  field :access_token,   type: String
end