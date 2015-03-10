class CarComment < Comment
  belongs_to :car,
    inverse_of: :comments,
    foreign_key: :commentable_id,
    counter_cache: :comments_count,
    required: true
end
