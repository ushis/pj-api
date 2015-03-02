class Car < ActiveRecord::Base
  has_many :rides,         inverse_of: :car, dependent: :destroy
  has_many :reservations,  inverse_of: :car, dependent: :destroy
  has_many :relationships, inverse_of: :car, dependent: :destroy
  has_many :ownerships,    inverse_of: :car
  has_many :borrowerships, inverse_of: :car
  has_many :users,         through: :relationships, source: :user
  has_many :owners,        through: :ownerships,    source: :user
  has_many :borrowers,     through: :borrowerships, source: :user

  has_many :comments,
    inverse_of: :car,
    dependent: :destroy,
    class_name: :CarComment,
    foreign_key: :commentable_id

  has_one :position, inverse_of: :car, dependent: :destroy

  validates :name,   presence: true, length: {maximum: 255}

  # Searches cars by (partial) name
  def self.search(q)
    where('name LIKE ?', "%#{q}%")
  end

  # Returns the cars position or raises ActiveRecord::RecordNotFound
  def position!
    position || raise(ActiveRecord::RecordNotFound,
                        "Couldn't find Position for Car with 'id'=#{id}")
  end
end
