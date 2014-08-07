# Read about factories at https://github.com/thoughtbot/factory_girl
module Light
FactoryGirl.define do
  factory :user, class: User do |u|
    u.email_id      {Faker::Internet.email}
    u.is_subscribed {true}
    u.joined_on     {Faker::Business.credit_card_expiry_date}
    u.source        {Faker::Name.name}
    u.username      {Faker::Name.name}
    newsletter
  end
end
end
