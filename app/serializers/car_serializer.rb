class CarSerializer < ApplicationSerializer
  attributes :id,
    :name,
    :mileage,
    :rides_count,
    :owners_count,
    :borrowers_count,
    :created_at,
    :updated_at

  has_one :position
end
