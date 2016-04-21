FactoryGirl.define do
  factory :car_comment do
    user
    car
    comment { SecureRandom.uuid }
  end
end
