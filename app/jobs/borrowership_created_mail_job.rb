class BorrowershipCreatedMailJob < ApplicationJob

  def perform(borrowership, user)
    recipients = borrowership.car.owners.exclude(user) << borrowership.user

    recipients.each do |owner|
      BorrowershipMailer.create(owner, borrowership, user).deliver_now
    end
  end
end
