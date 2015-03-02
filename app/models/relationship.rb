class Relationship < ActiveRecord::Base
  attr_accessor :invitation

  belongs_to :user, inverse_of: :relationships, required: true
  belongs_to :car,  inverse_of: :relationships, required: true

  validates :user_id, uniqueness: {scope: :car_id}

  # Searches relationships by (partial) username
  def self.search(q)
    joins(:user).where('users.username LIKE ?', "%#{q}%")
  end
end
