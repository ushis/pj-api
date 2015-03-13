class RideCommentCreatedMailJob < ApplicationJob

  def perform(comment)
    @comment = comment

    recipients.each do |user|
      RideCommentMailer.create(user, comment).deliver_now
    end
  end

  private

  def recipients
    (owners + commenters).tap do |users|
      users << driver if driver != commenter
    end
  end

  def commenter
    @commenter ||= @comment.user
  end

  def driver
    @driver ||= @comment.ride.user
  end

  def owners
    @owners ||= @comment.ride.car.owners.exclude(driver, commenter)
  end

  def commenters
    @commenters ||= @comment.ride.commenters.exclude(driver, commenter, *owners).distinct
  end
end
