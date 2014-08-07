# Read about factories at https://github.com/thoughtbot/factory_girl
module Light
FactoryGirl.define do
  factory :spreadsheet, class: Spreadsheet do |s|
    s.spreadsheet_id            {'1g2JX-w0XtcWD7yZo-K3cSHs7PhycCwhaYYmwajsLIwE'}
    s.spreadsheet_title         {'namecollection'}
    s.sequence(:access_token)   {|n| "#{n}ya29.QgC-kYKwAzcdh8AAABnuwXicpaXRvO_YSlv4V9J556542KazsYWEia63TlRyA"}
    s.refresh_token             {'1/DlAqfSUji69F3YuVAHSoWxWE0grR8aYSkb2OocVCNBw'}
    s.expires_at                {Time.now - 3600}
  end
end
end
