class CarMailer < ApplicationMailer

  def destroy(user, destroyer, car_name)
    @mail = CarDestroyedMail.new(user, destroyer, car_name)
    mail(@mail.header)
  end
end
