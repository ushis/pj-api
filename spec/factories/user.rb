FactoryGirl.define do
  factory :user do
    username { SecureRandom.hex(8) }
    email { "#{SecureRandom.uuid}@example.com" }
    password { SecureRandom.uuid }
    password_confirmation { password }

    trait :with_owned_cars do
      after(:create) { |user| user.owned_cars = create_list(:car, 2) }
    end

    trait :with_borrowed_cars do
      after(:create) { |user| user.borrowed_cars = create_list(:car, 2) }
    end

    trait :with_owned_and_borrowed_cars do
      with_owned_cars
      with_borrowed_cars
    end
  end
end
