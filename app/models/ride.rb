class Ride < ActiveRecord::Base
  include OrderBy

  belongs_to :user, inverse_of: :rides, optional: true
  belongs_to :car,  inverse_of: :rides, counter_cache: true

  has_many :comments,
    inverse_of: :ride,
    dependent: :destroy,
    class_name: :RideComment,
    foreign_key: :commentable_id,
    counter_cache: :comments_count

  has_many :commenters, through: :comments, source: :user

  validates :distance,    presence: true, numericality: {greater_than: 0}
  validates :started_at,  presence: true
  validates :ended_at,    presence: true

  validate :ensure_started_at_is_before_ended_at

  after_save :update_car_mileage

  after_destroy :update_car_mileage

  order_by_attributes :id,
    :distance,
    :started_at,
    :ended_at,
    :created_at,
    :updated_at

  scope :before, -> (date) { date.blank? ? all : where('started_at < ?', date) }
  scope :after, -> (date) { date.blank? ? all : where('ended_at > ?', date) }

  private

  # Validates that started_at is before ended_at
  def ensure_started_at_is_before_ended_at
    if started_at && ended_at && started_at >= ended_at
      errors.add(:ended_at, :is_before_started_at)
    end
  end

  # After save/destroy callback to update the cars mileage
  def update_car_mileage
    car.update_mileage
  end
end
