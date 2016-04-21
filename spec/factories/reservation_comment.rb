FactoryGirl.define do
  factory :reservation_comment do
    user
    reservation
    comment { SecureRandom.uuid }
  end
end
