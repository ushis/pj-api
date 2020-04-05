class CancelationSerializer < ApplicationSerializer
  attributes :created_at, :updated_at

  has_one :user, serializer: UserSerializer
end
