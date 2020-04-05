class ReservationSerializer < ApplicationSerializer
  attributes :id,
    :starts_at,
    :ends_at,
    :comments_count,
    :created_at,
    :updated_at

  has_one :user, serializer: UserSerializer
  has_one :cancelation, serializer: CancelationSerializer
end
