class ReservationComment < Comment
  belongs_to :reservation,
    inverse_of: :comments,
    foreign_key: :commentable_id,
    required: true
end
