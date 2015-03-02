class Reservation < ActiveRecord::Base
  belongs_to :user, inverse_of: :reservations, required: true
  belongs_to :car,  inverse_of: :reservations, required: true

  has_many :comments,
    inverse_of: :reservation,
    dependent: :destroy,
    class_name: :ReservationComment,
    foreign_key: :commentable_id

  validates :starts_at, presence: true
  validates :ends_at,   presence: true

  validate :ensure_starts_at_is_before_ends_at

  private

  # Validates that starts_at is before ends_at
  def ensure_starts_at_is_before_ends_at
    if starts_at && ends_at && starts_at >= ends_at
      errors.add(:ends_at, :is_before_starts_at)
    end
  end
end
