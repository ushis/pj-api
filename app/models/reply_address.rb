class ReplyAddress < Struct.new(:user, :record)
  class InvalidAddress < StandardError; end

  def self.decode(address)
    new(*GIDTag.decode(TaggedAddress.new(address).tag.to_s).records)
  rescue GIDTag::InvalidTag, Mail::Field::ParseError
    raise InvalidAddress
  end

  def to_s
    TaggedAddress.new(ENV.fetch('MAIL_REPLY')).tap do |address|
      address.tag = GIDTag.new(user, record).to_s
      address.display_name = record.car.name
    end.to_s
  end
end
