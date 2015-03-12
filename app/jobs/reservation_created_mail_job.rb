class ReservationCreatedMailJob < ApplicationJob

  def perform(reservation)
    reservation.car.owners.exclude(reservation.user).each do |user|
      ReservationMailer.create(user, reservation).deliver_now
    end
  end
end
