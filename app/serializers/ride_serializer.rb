class RideSerializer < ApplicationSerializer
  attributes :id,
    :distance,
    :started_at,
    :ended_at,
    :comments_count,
    :created_at,
    :updated_at

  has_one :user, serializer: UserSerializer
end
