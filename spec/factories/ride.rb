FactoryGirl.define do
  factory :ride do
    user
    car
    distance { rand(1_000) + 1 }
    started_at { 3.days.ago }
    ended_at { 1.day.ago }
  end
end
