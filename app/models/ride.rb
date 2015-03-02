class Ride < ActiveRecord::Base
  belongs_to :user, inverse_of: :rides
  belongs_to :car,  inverse_of: :rides, required: true


  has_many :comments,
    inverse_of: :ride,
    dependent: :destroy,
    class_name: :RideComment,
    foreign_key: :commentable_id

  validates :distance,    presence: true, numericality: {greater_than: 0}
  validates :started_at,  presence: true
  validates :ended_at,    presence: true

  validate :ensure_startet_at_is_before_ended_at

  private

  # Validates that started_at is before ended_at
  def ensure_startet_at_is_before_ended_at
    if started_at && ended_at && started_at >= ended_at
      errors.add(:ended_at, :is_before_startet_at)
    end
  end
end
