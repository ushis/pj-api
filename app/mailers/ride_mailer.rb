class RideMailer < ApplicationMailer

  def create(user, ride)
    @mail = RideCreatedMail.new(user, ride.user, ride)
    mail(@mail.header)
  end
end
