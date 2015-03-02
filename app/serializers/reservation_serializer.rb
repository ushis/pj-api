class ReservationSerializer < ApplicationSerializer
  attributes :id, :starts_at, :ends_at, :created_at, :updated_at

  has_one :user
end
