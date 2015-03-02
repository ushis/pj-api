class CarSerializer < ApplicationSerializer
  attributes :id, :name, :created_at, :updated_at

  has_one :position
end
