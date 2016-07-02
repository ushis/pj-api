class RideComment < Comment
  belongs_to :ride,
    inverse_of: :comments,
    foreign_key: :commentable_id,
    counter_cache: :comments_count
end
