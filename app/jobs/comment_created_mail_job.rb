class CommentCreatedMailJob < ApplicationJob

  def perform(comment)
    case comment
    when CarComment
      CarCommentCreatedMailJob.perform_now(comment)
    when ReservationComment
      ReservationCommentCreatedMailJob.perform_now(comment)
    when RideComment
      RideCommentCreatedMailJob.perform_now(comment)
    end
  end
end
