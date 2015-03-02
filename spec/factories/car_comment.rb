FactoryGirl.define do
  factory :car_comment do
    user
    car
    comment { SecureRandom.hex(32) }
  end
end
