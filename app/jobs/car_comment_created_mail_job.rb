class CarCommentCreatedMailJob < ApplicationJob

  def perform(comment)
    @comment = comment

    recipients.each do |user|
      CarCommentMailer.create(user, comment).deliver_now
    end
  end

  private

  def recipients
    owners + commenters
  end

  def commenter
    @commenter ||= @comment.user
  end

  def owners
    @owners ||= @comment.car.owners.exclude(commenter)
  end

  def commenters
    @commenters ||= @comment.car.commenters.exclude(commenter, *owners).distinct
  end
end
