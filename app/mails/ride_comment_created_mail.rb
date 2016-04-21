class RideCommentCreatedMail < ApplicationMail

  def car
    ride.car
  end

  def ride
    comment.ride
  end

  def comment
    record
  end

  def app_url
    original_mail.app_url
  end

  def subject
    "Re: #{original_mail.subject}"
  end

  def reply_to
    original_mail.reply_to
  end

  def message_id
    MessageID.new(car, ride, comment).to_s
  end

  def in_reply_to
    original_mail.message_id
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

  private

  def original_mail
    @original_mail ||= RideCreatedMail.new(recipient, ride.user, ride)
  end
end