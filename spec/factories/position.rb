FactoryGirl.define do
  factory :position do
    car
    latitude { (rand * 180) - 90 }
    longitude { (rand * 360) - 180 }
  end
end
