class RideCommentCreatedMail < RideCreatedMail

  def car
    ride.car
  end

  def ride
    comment.ride
  end

  def comment
    record
  end

  def subject
    "Re: #{super}"
  end

  def message_id
    MessageID.new(car, ride, comment).to_s
  end

  def in_reply_to
    RideCreatedMail.new(recipient, sender, ride).message_id
  end

  alias :references :in_reply_to

  def header
    super.merge({
      references: references,
      in_reply_to: in_reply_to
    })
  end
end
