class LocationUpdatedMailJob < ApplicationJob

  def perform(location)
    location.car.owners.exclude(location.user).each do |user|
      LocationMailer.update(user, location).deliver_now
    end
  end
end
