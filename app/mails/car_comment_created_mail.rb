class CarCommentCreatedMail < ApplicationMail

  def car
    comment.car
  end

  def comment
    record
  end

  def url
    app_url("/cars/#{car.id}/comments")
  end

  def subject
    "Re: Discussion about #{car.name}"
  end

  def reply_to
    reply_address.to_s
  end

  def message_id
    MessageID.new(car, comment).to_s
  end

  def in_reply_to
    MessageID.new(car).to_s
  end

  alias :references :in_reply_to

  def list_id
    ListID.new(car).to_s
  end

  def list_archive
    app_url("/cars/#{car.id}/location")
  end

  def list_post
    "<mailto:#{reply_address.address}>"
  end

  def header
    super.merge({
      reply_to: reply_to,
      references: references,
      in_reply_to: in_reply_to,
      'List-ID': list_id,
      'List-Post': list_post,
      'List-Archive': list_archive
    })
  end

  private

  def reply_address
    ReplyAddress.new(recipient, car, car.name)
  end
end
