class RideCreatedMailJob < ApplicationJob

  def perform(ride)
    ride.car.owners.exclude(ride.user).each do |user|
      RideMailer.create(user, ride).deliver_now
    end
  end
end
