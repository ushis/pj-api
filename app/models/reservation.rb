class Reservation < ActiveRecord::Base
  include OrderBy

  belongs_to :user, inverse_of: :reservations
  belongs_to :car,  inverse_of: :reservations

  has_one :cancelation, inverse_of: :reservation, dependent: :destroy

  has_many :comments,
    inverse_of: :reservation,
    dependent: :destroy,
    class_name: :ReservationComment,
    foreign_key: :commentable_id,
    counter_cache: :comments_count

  has_many :commenters, through: :comments, source: :user

  validates :starts_at, presence: true
  validates :ends_at,   presence: true

  validate :ensure_starts_at_is_before_ends_at

  order_by_attributes :id, :starts_at, :ends_at, :created_at, :updated_at

  scope :before, -> (date) { date.blank? ? all : where('starts_at < ?', date) }
  scope :after, -> (date) { date.blank? ? all : where('ends_at > ?', date) }

  def cancelled?
    cancelation.present?
  end

  def cancelation!
    cancelation || raise(ActiveRecord::RecordNotFound,
                         "Couldn't find Cancelation for Reservation with 'id'=#{id}")
  end

  private

  # Validates that starts_at is before ends_at
  def ensure_starts_at_is_before_ends_at
    if starts_at && ends_at && starts_at >= ends_at
      errors.add(:ends_at, :is_before_starts_at)
    end
  end
end
