class OwnershipCreatedMailJob < ApplicationJob

  def perform(ownership, user)
    ownership.car.owners.exclude(user).each do |owner|
      OwnershipMailer.create(owner, ownership, user).deliver_now
    end
  end
end
