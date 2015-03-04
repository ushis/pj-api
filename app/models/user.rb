class User < ActiveRecord::Base
  include HasToken

  has_token :access, 1.week

  has_secure_password validations: false

  has_many :comments,      inverse_of: :user, dependent: :nullify
  has_many :rides,         inverse_of: :user, dependent: :nullify
  has_many :reservations,  inverse_of: :user, dependent: :destroy
  has_many :relationships, inverse_of: :user, dependent: :destroy
  has_many :ownerships,    inverse_of: :user
  has_many :borrowerships, inverse_of: :user
  has_many :cars,          through: :relationships, source: :car
  has_many :owned_cars,    through: :ownerships,    source: :car
  has_many :borrowed_cars, through: :borrowerships, source: :car

  validates :username, presence: true, uniqueness: true,
    length: {maximum: 255}, format: /\A[a-z0-9]+\z/

  validates :email,    presence: true, uniqueness: true,
    length: {maximum: 255}, format: /.+@.+/

  validates :password, presence: true,
    if: -> (u) { !u.password_digest.present? }

  validates :password, confirmation: true

  validates :password_confirmation, presence: true,
    if: -> (u) { u.password.present? }

  before_validation -> (u) { u.username = u.username.to_s.strip.downcase }
  before_validation -> (u) { u.email = u.email.to_s.strip }

  scope :exclude, -> (*users) { users.empty? ? all : where.not(id: users) }

  # Finds a user by username/email
  def self.find_by_username_or_email(username_or_email)
    where('username = :q OR email = :q', q: username_or_email).first
  end

  # Searches users by (partial) username
  def self.search(q)
    q.blank? ? all : where('username LIKE ?', "%#{q}%")
  end

  # Returns true if the given is owned or borrowed by the user else false
  def owns_or_borrows?(car)
    cars.include?(car)
  end

  # Returns true if the given car is owned by the user else false
  def owns?(car)
    owned_cars.include?(car)
  end

  # Returns true if the given cat is borrowed by the user else false
  def borrows?(car)
    borrowed_cars.include?(car)
  end
end
