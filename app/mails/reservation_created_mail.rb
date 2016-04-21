class ReservationCreatedMail < ApplicationMail

  def car
    reservation.car
  end

  def reservation
    record
  end

  def app_url
    super("/cars/#{car.id}/reservations/#{reservation.id}/comments")
  end

  def subject
    "I need #{car.name} between #{formatted_starts_at} and #{formatted_ends_at}"
  end

  def reply_to
    ReplyAddress.new(recipient, reservation, car.name).to_s
  end

  def message_id
    MessageID.new(car, reservation).to_s
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

  def formatted_starts_at
    format_datetime(reservation.starts_at)
  end

  def formatted_ends_at
    format_datetime(reservation.ends_at)
  end
end
