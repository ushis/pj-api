class ReservationCreatedMail < ApplicationMail

  def car
    reservation.car
  end

  def reservation
    record
  end

  def url
    app_url("/cars/#{car.id}/reservations/#{reservation.id}/comments")
  end

  def subject
    "I need #{car.name} between #{formatted_starts_at} and #{formatted_ends_at}"
  end

  def reply_to
    reply_address.to_s
  end

  def message_id
    MessageID.new(car, reservation).to_s
  end

  def list_id
    ListID.new(car).to_s
  end

  def list_archive
    app_url("/cars/#{car.id}/location")
  end

  def list_post
    "<mailto:#{reply_address.address}>"
  end

  def header
    super.merge({
      reply_to: reply_to,
      'List-ID': list_id,
      'List-Post': list_post,
      'List-Archive': list_archive
    })
  end

  def formatted_starts_at
    format_datetime(reservation.starts_at)
  end

  def formatted_ends_at
    format_datetime(reservation.ends_at)
  end

  private

  def reply_address
    ReplyAddress.new(recipient, reservation, car.name)
  end
end
