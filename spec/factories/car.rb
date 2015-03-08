FactoryGirl.define do
  factory :car do
    name { SecureRandom.uuid }

    trait :with_location do
      location
    end

    trait :with_rides do
      after(:create) { |car| create_list(:ride, 2, car: car) }
    end
  end
end
