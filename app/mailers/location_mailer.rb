class LocationMailer < ApplicationMailer

  def update(user, location)
    @user = user
    @location = location
    @url = location_url
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    "#{@location.user.username} updated the location of #{@location.car.name}"
  end

  def location_url
    app_url("/cars/#{@location.car.id}/location")
  end
end
