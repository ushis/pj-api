FactoryGirl.define do
  factory :car do
    name { SecureRandom.uuid }

    trait :with_position do
      position
    end
  end
end
