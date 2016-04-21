class ApplicationMail < Struct.new(:recipient, :sender, :record)

  def to
    recipient.email_with_username
  end

  def from
    from_address.tap { |addr| addr.display_name = sender.username }.to_s
  end

  def message_id
    "<#{from_address.tap { |addr| addr.local = SecureRandom.uuid}.address}>"
  end

  def app_url(path)
    "#{ENV['APP_HOST']}/##{path}"
  end

  private

  def from_address
    TaggedAddress.new(ENV.fetch('MAIL_FROM'))
  end

  def format_datetime(datetime)
    datetime.in_time_zone(recipient.time_zone).strftime('%d %b %Y, %H:%M')
  end
end
