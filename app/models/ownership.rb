class Ownership < Relationship
  belongs_to :user, inverse_of: :ownerships, required: true
  belongs_to :car,  inverse_of: :ownerships, required: true
end
