class LocationSerializer < ApplicationSerializer
  attributes :latitude, :longitude, :created_at, :updated_at

  has_one :user

  def latitude
    object.latitude.to_f
  end

  def longitude
    object.longitude.to_f
  end
end
