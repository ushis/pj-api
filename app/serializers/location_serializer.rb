class LocationSerializer < ApplicationSerializer
  attributes :latitude, :longitude, :created_at, :updated_at

  has_one :user
end
