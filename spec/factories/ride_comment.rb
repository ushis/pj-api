FactoryGirl.define do
  factory :ride_comment do
    user
    ride
    comment { SecureRandom.uuid }
  end
end
