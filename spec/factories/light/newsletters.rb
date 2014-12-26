# Read about factories at https://github.com/thoughtbot/factory_girl
module Light
  FactoryGirl.define do
    factory :newsletter, class: Newsletter do |u|
      u.content    {Faker::Name.name}
      u.subject    {Faker::Name.name}
      u.sent_on    {Faker::Business.credit_card_expiry_date}
    end
  end
end
