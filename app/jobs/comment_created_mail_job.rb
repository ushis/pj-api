class CommentCreatedMailJob < ApplicationJob

  def perform(comment)
    case comment
    when CarComment
      handle_car_comment(comment)
    when ReservationComment
      handle_reservation_comment(comment)
    when RideComment
      handle_ride_comment(comment)
    end
  end

  private

  def handle_car_comment(comment)
    owners = comment.car.owners.exclude(comment.user)
    commenters = comment.car.commenters.exclude(comment.user, *owners).distinct

    owners.concat(commenters).each do |user|
      CarCommentMailer.create(user, comment).deliver_now
    end
  end

  def handle_reservation_comment(comment)
    applier = comment.reservation.user
    owners = comment.reservation.car.owners.exclude(applier, comment.user)
    commenters = comment.reservation.commenters.exclude(applier, comment.user, *owners).distinct

    owners.concat(commenters).each do |user|
      ReservationCommentMailer.create(user, comment).deliver_now
    end

    if applier != comment.user
      ReservationCommentMailer.create(applier, comment).deliver_now
    end
  end

  def handle_ride_comment(comment)
    driver = comment.ride.user
    owners = comment.ride.car.owners.exclude(driver, comment.user)
    commenters = comment.ride.commenters.exclude(driver, comment.user, *owners).distinct

    owners.concat(commenters).each do |user|
      RideCommentMailer.create(user, comment).deliver_now
    end

    if driver != comment.user
      RideCommentMailer.create(driver, comment).deliver_now
    end
  end
end
