module ApiHelper

  def set_auth_header(token)
    request.headers['Authorization'] = "Bearer #{token}" if token.present?
  end

  def json
    @json ||= JSON.parse(response.body).deep_symbolize_keys
  end

  def session_json(user)
    profile_json(user).merge!({
      access_token: user.access_token
    })
  end

  def profile_json(user)
    user_json(user).merge!({
      email: user.email,
      created_at: user.created_at.as_json,
      updated_at: user.updated_at.as_json
    })
  end

  def users_json(users)
    users.map { |user| user_json(user) }
  end

  def user_json(user)
    {
      id: user.id,
      username: user.username
    }
  end

  def cars_json(cars)
    cars.map { |car| car_json(car) }
  end

  def car_json(car)
    {
      id: car.id,
      name: car.name,
      mileage: car.mileage,
      rides_count: car.rides_count,
      position: car.position.present? ? position_json(car.position) : nil,
      created_at: car.created_at.as_json,
      updated_at: car.updated_at.as_json
    }
  end

  def position_json(position)
    {
      latitude: position.latitude,
      longitude: position.longitude,
      created_at: position.created_at.as_json,
      updated_at: position.updated_at.as_json
    }
  end

  def rides_json(rides)
    rides.map { |ride| ride_json(ride) }
  end

  def ride_json(ride)
    {
      id: ride.id,
      distance: ride.distance,
      started_at: ride.started_at.as_json,
      ended_at: ride.ended_at.as_json,
      user: ride.user.present? ? user_json(ride.user) : nil,
      created_at: ride.created_at.as_json,
      updated_at: ride.updated_at.as_json
    }
  end

  def reservations_json(reservations)
    reservations.map { |reservation| reservation_json(reservation) }
  end

  def reservation_json(reservation)
    {
      id: reservation.id,
      starts_at: reservation.starts_at.as_json,
      ends_at: reservation.ends_at.as_json,
      user: user_json(reservation.user),
      created_at: reservation.created_at.as_json,
      updated_at: reservation.updated_at.as_json
    }
  end

  def comments_json(comments)
    comments.map { |comment| comment_json(comment) }
  end

  def comment_json(comment)
    {
      id: comment.id,
      comment: comment.comment,
      user: comment.user.present? ? user_json(comment.user) : nil,
      created_at: comment.created_at.as_json,
      updated_at: comment.updated_at.as_json
    }
  end

  def ownerships_json(ownerships)
    ownerships.map { |ownership| ownership_json(ownership) }
  end

  def ownership_json(ownership)
    {
      id: ownership.id,
      user: user_json(ownership.user),
      created_at: ownership.created_at.as_json,
      updated_at: ownership.updated_at.as_json
    }
  end

  def borrowerships_json(borrowerships)
    borrowerships.map { |borrowership| borrowership_json(borrowership) }
  end

  def borrowership_json(borrowership)
    {
      id: borrowership.id,
      user: user_json(borrowership.user),
      created_at: borrowership.created_at.as_json,
      updated_at: borrowership.updated_at.as_json
    }
  end
end
