class LocationMailer < ApplicationMailer

  def update(user, location)
    @mail = LocationUpdatedMail.new(user, location.user, location)
    mail(@mail.header)
  end
end
