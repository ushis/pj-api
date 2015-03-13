class CarCommentMailer < ApplicationMailer

  def create(user, comment)
    @comment = comment
    @url = comment_url(comment)
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    "#{@comment.user.username} left a comment on #{@comment.car.name}"
  end

  def comment_url(comment)
    app_url("/cars/#{comment.car.id}/comments")
  end
end
