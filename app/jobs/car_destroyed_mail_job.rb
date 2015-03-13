class CarDestroyedMailJob < ApplicationJob

  def perform(car_name, user, *recipients)
    recipients.each do |recipient|
      CarMailer.destroy(recipient, car_name, user).deliver_now
    end
  end
end
