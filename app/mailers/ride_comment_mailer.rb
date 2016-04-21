class RideCommentMailer < ApplicationMailer

  def create(user, comment)
    @mail = RideCommentCreatedMail.new(user, comment.user, comment)
    mail(@mail.header)
  end
end
