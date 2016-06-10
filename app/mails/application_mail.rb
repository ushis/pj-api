class ApplicationMail
  attr_reader :recipient, :sender, :record

  def initialize(recipient, sender=nil, record=nil)
    @recipient = recipient
    @sender = sender
    @record = record
  end

  def to
    Mail::Address.new(recipient.email).tap do |addr|
      addr.display_name = recipient.username
    end.to_s
  end

  def from
    from_address.tap do |addr|
      addr.display_name = sender.username if sender.present?
    end.to_s
  end

  def message_id
    "<#{from_address.tap { |addr| addr.local = SecureRandom.uuid}.address}>"
  end

  def header
    {
      to: to,
      from: from,
      subject: subject,
      message_id: message_id
    }
  end

  private

  def from_address
    TaggedAddress.new(ENV.fetch('MAIL_FROM'))
  end

  def app_url(path)
    "#{ENV['APP_HOST']}/##{path}"
  end

  def format_datetime(datetime)
    datetime.in_time_zone(recipient.time_zone).strftime('%d %b %Y, %H:%M')
  end
end
