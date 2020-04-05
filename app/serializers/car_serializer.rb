class CarSerializer < ApplicationSerializer
  attributes :id,
    :name,
    :mileage,
    :rides_count,
    :owners_count,
    :borrowers_count,
    :comments_count,
    :created_at,
    :updated_at,
    :current_user

  has_one :location, serializer: LocationSerializer

  def current_user
    {owner: object.owned_by?(scope)}
  end
end
