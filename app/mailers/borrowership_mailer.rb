class BorrowershipMailer < ApplicationMailer

  def create(user, creator, borrowership)
    @mail = BorrowershipCreatedMail.new(user, creator, borrowership)
    mail(@mail.header)
  end
end
