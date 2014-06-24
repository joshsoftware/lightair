# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :newsletter do |u|
    u.content    {Faker::Name.name}
    u.sent_on    {Faker::Business.credit_card_expiry_date}
    u.user_count {Faker::Number.number(5)}
  end
end
