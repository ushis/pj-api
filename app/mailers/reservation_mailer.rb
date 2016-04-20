class ReservationMailer < ApplicationMailer

  def create(user, reservation)
    @user = user
    @reservation = reservation
    @url = reservation_url
    mail(to: user.email_with_username, subject: subject, reply_to: reply_to)
  end

  private

  def subject
    "#{@reservation.user.username} added a new reservation to #{@reservation.car.name}"
  end

  def reservation_url
    app_url("/cars/#{@reservation.car.id}/reservations/#{@reservation.id}/comments")
  end

  def reply_to
    ReplyAddress.new(@user, @reservation, @reservation.car.name).to_s
  end
end
