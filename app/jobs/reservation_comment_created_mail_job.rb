class ReservationCommentCreatedMailJob < ApplicationJob

  def perform(comment)
    @comment = comment

    recipients.each do |user|
      ReservationCommentMailer.create(user, comment).deliver_now
    end
  end

  private

  def recipients
    (owners + commenters).tap do |users|
      users << applier if applier != commenter
    end
  end

  def commenter
    @commenter ||= @comment.user
  end

  def applier
    @applier ||= @comment.reservation.user
  end

  def owners
    @owners ||= @comment.reservation.car.owners.exclude(applier, commenter)
  end

  def commenters
    @commenters ||= @comment.reservation.commenters.exclude(applier, commenter, *owners).distinct
  end
end
