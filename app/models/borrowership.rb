class Borrowership < Relationship
  belongs_to :user, inverse_of: :borrowerships
  belongs_to :car,  inverse_of: :borrowerships, counter_cache: :borrowers_count
end
