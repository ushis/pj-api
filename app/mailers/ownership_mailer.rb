class OwnershipMailer < ApplicationMailer

  def create(user, creator, ownership)
    @mail = OwnershipCreatedMail.new(user, creator, ownership)
    mail(@mail.header)
  end
end
