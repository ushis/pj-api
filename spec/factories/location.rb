FactoryGirl.define do
  factory :location do
    user
    car
    latitude { (rand * 180) - 90 }
    longitude { (rand * 360) - 180 }
  end
end
