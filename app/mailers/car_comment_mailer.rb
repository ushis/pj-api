class CarCommentMailer < ApplicationMailer

  def create(user, comment)
    @mail = CarCommentCreatedMail.new(user, comment.user, comment)
    mail(@mail.header)
  end
end
