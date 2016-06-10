class OwnershipCreatedMail < ApplicationMail

  def car
    ownership.car
  end

  def ownership
    record
  end

  def url
    if ownership.user == recipient
      app_url("/cars/#{car.id}/location")
    else
      app_url("/cars/#{car.id}/owners")
    end
  end

  def subject
    if ownership.user == recipient
      "I declared you owner of #{car.name}"
    else
      "I declared #{ownership.user.username} owner of #{car.name}"
    end
  end
end
