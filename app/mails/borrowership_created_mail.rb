class BorrowershipCreatedMail < ApplicationMail

  def car
    borrowership.car
  end

  def borrowership
    record
  end

  def url
    if borrowership.user == recipient
      app_url("/cars/#{car.id}/location")
    else
      app_url("/cars/#{car.id}/borrowers")
    end
  end

  def subject
    if borrowership.user == recipient
      "I added you to #{car.name}"
    else
      "I added #{borrowership.user.username} to #{car.name}"
    end
  end
end
