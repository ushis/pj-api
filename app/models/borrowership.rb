class Borrowership < Relationship
  belongs_to :user, inverse_of: :borrowerships, required: true

  belongs_to :car,
    inverse_of: :borrowerships,
    counter_cache: :borrowers_count,
    required: true
end
