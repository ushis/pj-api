class CarCommentMailer < ApplicationMailer

  def create(user, comment)
    @user = user
    @comment = comment
    @url = comment_url
    mail(to: user.email_with_username, subject: subject, reply_to: reply_to)
  end

  private

  def subject
    "#{@comment.user.username} left a comment on #{@comment.car.name}"
  end

  def comment_url
    app_url("/cars/#{@comment.car.id}/comments")
  end

  def reply_to
    ReplyAddress.new(@user, @comment.car, @comment.car.name).to_s
  end
end
