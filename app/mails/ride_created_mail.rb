class RideCreatedMail < ApplicationMail

  def car
    ride.car
  end

  def ride
    record
  end

  def url
    app_url("/cars/#{car.id}/rides/#{ride.id}/comments")
  end

  def subject
    "I took #{car.name} for a #{ride.distance} km ride"
  end

  def reply_to
    reply_address.to_s
  end

  def message_id
    MessageID.new(car, ride).to_s
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

  def formatted_started_at
    format_datetime(ride.started_at)
  end

  def formatted_ended_at
    format_datetime(ride.ended_at)
  end

  private

  def reply_address
    ReplyAddress.new(recipient, ride, car.name)
  end
end
