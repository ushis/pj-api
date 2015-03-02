class CommentSerializer < ApplicationSerializer
  attributes :id, :comment, :created_at, :updated_at

  has_one :user
end
