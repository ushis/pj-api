class Comment < ActiveRecord::Base
  belongs_to :user

  validates :user,    presence: true, on: :create
  validates :comment, presence: true
end
