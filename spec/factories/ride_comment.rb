FactoryGirl.define do
  factory :ride_comment do
    user
    ride
    comment { SecureRandom.hex(32) }
  end
end
