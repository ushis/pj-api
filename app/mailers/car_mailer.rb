class CarMailer < ApplicationMailer

  def destroy(user, car_name, destroyer)
    @user = user
    @car_name = car_name
    @destroyer = destroyer
    @url = app_url('/cars')
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    "#{@destroyer.username} deleted #{@car_name}"
  end
end
