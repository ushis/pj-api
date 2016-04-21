class BorrowershipCreatedMail < ApplicationMail

  def car
    borrowership.car
  end

  def borrowership
    record
  end

  def app_url
    if borrowership.user == recipient
      super("/cars/#{car.id}/location")
    else
      super("/cars/#{car.id}/borrowers")
    end
  end

  def subject
    if borrowership.user == recipient
      "I added you to #{car.name}"
    else
      "I added #{borrowership.user.username} to #{car.name}"
    end
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
