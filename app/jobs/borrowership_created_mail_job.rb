class BorrowershipCreatedMailJob < ApplicationJob

  def perform(borrowership, user)
    recipients = borrowership.car.owners.exclude(user).to_a << borrowership.user

    recipients.each do |recipient|
      BorrowershipMailer.create(recipient, user, borrowership).deliver_now
    end
  end
end
