class RideSerializer < ApplicationSerializer
  attributes :id, :distance, :started_at, :ended_at, :created_at, :updated_at

  has_one :user
end
