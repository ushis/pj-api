class Relationship < ActiveRecord::Base
  include OrderBy

  belongs_to :user, inverse_of: :relationships
  belongs_to :car,  inverse_of: :relationships

  validates :user_id, uniqueness: {scope: :car_id}

  order_by_attributes :id, :created_at, :updated_at, user: :username

  # Searches relationships by (partial) username
  def self.search(q)
    q.blank? ? all : joins(:user).where('users.username LIKE ?', "%#{q}%")
  end
end
