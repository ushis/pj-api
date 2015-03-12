class LocationMailer < ApplicationMailer

  def update(user, location)
    @user = user
    @location = location
    @url = location_url(location)
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    "#{@user.username} updated the location of #{@location.car.name}"
  end

  def location_url(location)
    app_url("/cars/#{location.car.id}/location")
  end
end
