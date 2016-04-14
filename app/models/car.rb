class Car < ActiveRecord::Base
  include OrderBy

  has_many :rides,         inverse_of: :car, dependent: :destroy
  has_many :reservations,  inverse_of: :car, dependent: :destroy
  has_many :relationships, inverse_of: :car, dependent: :destroy
  has_many :ownerships,    inverse_of: :car, counter_cache: :owners_count
  has_many :borrowerships, inverse_of: :car, counter_cache: :borrowers_count
  has_many :users,         through: :relationships, source: :user
  has_many :owners,        through: :ownerships,    source: :user
  has_many :borrowers,     through: :borrowerships, source: :user

  has_many :comments,
    inverse_of: :car,
    dependent: :destroy,
    class_name: :CarComment,
    foreign_key: :commentable_id,
    counter_cache: :comments_count

  has_many :commenters, through: :comments, source: :user

  has_one :location, inverse_of: :car, dependent: :destroy

  validates :name,   presence: true, length: {maximum: 255}

  order_by_attributes :id, :name, :created_at, :updated_at

  # Searches cars by (partial) name
  def self.search(q)
    q.blank? ? all : where('name LIKE ?', "%#{q}%")
  end

  # Returns true if the given user owns the car else false
  def owned_by?(user)
    owners.include?(user)
  end

  # Returns true if the given user borrowes the car else false
  def borrowed_by?(user)
    borrowers.include?(user)
  end

  # Returns the cars location or raises ActiveRecord::RecordNotFound
  def location!
    location || raise(ActiveRecord::RecordNotFound,
                      "Couldn't find Location for Car with 'id'=#{id}")
  end

  # Updates the cars mileage
  def update_mileage
    update_attribute(:mileage, rides.sum(:distance))
  end

  # Returns self
  def car
    self
  end
end
