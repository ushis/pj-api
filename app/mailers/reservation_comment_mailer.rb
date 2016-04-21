class ReservationCommentMailer < ApplicationMailer

  def create(user, comment)
    @mail = ReservationCommentCreatedMail.new(user, comment.user, comment)
    mail(@mail.header)
  end
end
