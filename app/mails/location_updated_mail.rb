class LocationUpdatedMail < ApplicationMail

  def car
    location.car
  end

  def location
    record
  end

  def app_url
    super("/cars/#{car.id}/location")
  end

  def subject
    "I parked #{car.name} at a new location"
  end

  def header
    {
      to: to,
      from: from,
      subject: subject,
      message_id: message_id
    }
  end
end
