# Read about factories at https://github.com/thoughtbot/factory_girl
module Light
FactoryGirl.define do
  factory :newsletter, class: Newsletter do |u|
    u.content    {Faker::Name.name}
    u.subject    {Faker::Name.name}
    u.sent_on    {Faker::Business.credit_card_expiry_date}

    factory :newsletter_with_users do 
      ignore do 
        users_count 3
      end

      after(:create) do |newsletter, evaluator|
        create_list(:user,evaluator.users_count, newsletter: newsletter)
      end
    end
  end
end
end
