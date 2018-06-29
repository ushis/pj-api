FactoryBot.define do
  factory :reservation do
    user
    car
    starts_at { 1.day.from_now }
    ends_at { 3.days.from_now }
  end
end
