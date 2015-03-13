class RideCommentMailer < ApplicationMailer

  def create(user, comment)
    @user = user
    @comment = comment
    @url = comment_url(comment)
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    if @user == @comment.ride.user
      "#{@comment.user.username} left a comment on your ride with #{@comment.ride.car.name}"
    else
      "#{@comment.user.username} left a comment on a ride with #{@comment.ride.car.name}"
    end
  end

  def comment_url(comment)
    app_url("/cars/#{comment.ride.car.id}/rides/#{comment.ride.id}/comments")
  end
end
