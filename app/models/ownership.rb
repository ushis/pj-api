class Ownership < Relationship
  belongs_to :user, inverse_of: :ownerships, required: true

  belongs_to :car,
    inverse_of: :ownerships,
    counter_cache: :owners_count,
    required: true
end
