class Comment < ActiveRecord::Base
  include OrderBy

  belongs_to :user

  validates :user,    presence: true, on: :create
  validates :comment, presence: true

  order_by_attributes :id, :created_at
end
