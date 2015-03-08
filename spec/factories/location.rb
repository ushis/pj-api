FactoryGirl.define do
  factory :location do
    car
    latitude { (rand * 180) - 90 }
    longitude { (rand * 360) - 180 }
  end
end
