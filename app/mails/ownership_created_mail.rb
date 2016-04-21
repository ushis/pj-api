class OwnershipCreatedMail < ApplicationMail

  def car
    ownership.car
  end

  def ownership
    record
  end

  def app_url
    if ownership.user == recipient
      super("/cars/#{car.id}/location")
    else
      super("/cars/#{car.id}/owners")
    end
  end

  def subject
    if ownership.user == recipient
      "I declared you owner of #{car.name}"
    else
      "I declared #{ownership.user.username} owner of #{car.name}"
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
