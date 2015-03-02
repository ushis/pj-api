FactoryGirl.define do
  factory :reservation_comment do
    user
    reservation
    comment { SecureRandom.hex(32) }
  end
end
