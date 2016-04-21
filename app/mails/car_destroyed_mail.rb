class CarDestroyedMail < ApplicationMail

  def car_name
    record
  end

  def app_url
    super('/cars')
  end

  def subject
    "I deleted #{car_name}"
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
