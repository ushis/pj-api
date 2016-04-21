class CarDestroyedMailJob < ApplicationJob

  def perform(car_name, user, *recipients)
    recipients.each do |recipient|
      CarMailer.destroy(recipient, user, car_name).deliver_now
    end
  end
end
