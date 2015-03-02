class CarComment < Comment
  belongs_to :car,
    inverse_of: :comments,
    foreign_key: :commentable_id,
    required: true
end
