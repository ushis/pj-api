class ReservationCommentCreatedMail < ReservationCreatedMail

  def car
    reservation.car
  end

  def reservation
    comment.reservation
  end

  def comment
    record
  end

  def subject
    "Re: #{super}"
  end

  def message_id
    MessageID.new(car, reservation, comment).to_s
  end

  def in_reply_to
    ReservationCreatedMail.new(recipient, sender, reservation).message_id
  end

  alias :references :in_reply_to

  def header
    super.merge({
      references: references,
      in_reply_to: in_reply_to
    })
  end
end
