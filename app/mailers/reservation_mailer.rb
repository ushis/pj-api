class ReservationMailer < ApplicationMailer

  def create(user, reservation)
    @mail = ReservationCreatedMail.new(user, reservation.user, reservation)
    mail(@mail.header)
  end
end
