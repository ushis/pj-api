class RideCreatedMail < ApplicationMail

  def car
    ride.car
  end

  def ride
    record
  end

  def app_url
    super("/cars/#{car.id}/rides/#{ride.id}/comments")
  end

  def subject
    "I took #{car.name} for a #{ride.distance} km ride"
  end

  def reply_to
    ReplyAddress.new(recipient, ride, car.name).to_s
  end

  def message_id
    MessageID.new(car, ride).to_s
  end

  def header
    {
      to: to,
      from: from,
      subject: subject,
      reply_to: reply_to,
      message_id: message_id
    }
  end

  def formatted_started_at
    format_datetime(ride.started_at)
  end

  def formatted_ended_at
    format_datetime(ride.ended_at)
  end
end
