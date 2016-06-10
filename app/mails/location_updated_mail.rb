class LocationUpdatedMail < ApplicationMail

  def car
    location.car
  end

  def location
    record
  end

  def url
    app_url("/cars/#{car.id}/location")
  end

  def subject
    "I parked #{car.name} at a new location"
  end
end
