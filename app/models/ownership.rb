class Ownership < Relationship
  belongs_to :user, inverse_of: :ownerships
  belongs_to :car,  inverse_of: :ownerships, counter_cache: :owners_count
end
