class CarCommentCreatedMail < ApplicationMail

  def car
    comment.car
  end

  def comment
    record
  end

  def app_url
    super("/cars/#{car.id}/comments")
  end

  def subject
    "Re: Discussion about #{car.name}"
  end

  def reply_to
    ReplyAddress.new(recipient, car, car.name).to_s
  end

  def message_id
    MessageID.new(car, comment).to_s
  end

  def in_reply_to
    MessageID.new(car).to_s
  end

  alias :references :in_reply_to

  def header
    {
      to: to,
      from: from,
      subject: subject,
      reply_to: reply_to,
      message_id: message_id,
      references: references,
      in_reply_to: in_reply_to
    }
  end
end
