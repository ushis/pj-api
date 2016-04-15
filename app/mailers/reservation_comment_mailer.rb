class ReservationCommentMailer < ApplicationMailer

  def create(user, comment)
    @user = user
    @comment = comment
    @url = comment_url
    mail(to: user.email_with_username, subject: subject, reply_to: reply_to)
  end

  private

  def subject
    if @user == @comment.reservation.user
      "#{@comment.user.username} left a comment on your reservation for #{@comment.reservation.car.name}"
    else
      "#{@comment.user.username} left a comment on a reservation for #{@comment.reservation.car.name}"
    end
  end

  def comment_url
    app_url("/cars/#{@comment.reservation.car.id}/reservations/#{@comment.reservation.id}/comments")
  end

  def reply_to
    ReplyAddress.new(@user, @comment.reservation).to_s
  end
end
