class RideMailer < ApplicationMailer

  def create(user, ride)
    @user = user
    @ride = ride
    @url = ride_url
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    "#{@ride.user.username} added a new ride to #{@ride.car.name}"
  end

  def ride_url
    app_url("/cars/#{@ride.car.id}/rides/#{@ride.id}/comments")
  end
end
