class ReplyAddress
  class InvalidAddress < StandardError; end

  attr_reader :user, :record, :name

  def self.decode(address)
    addr = TaggedAddress.new(address)
    name = addr.display_name
    user, record = GIDTag.decode(addr.tag.to_s).records
    new(user, record, name)
  rescue GIDTag::InvalidTag, Mail::Field::ParseError
    raise InvalidAddress
  end

  def initialize(user, record, name=nil)
    @user = user
    @record = record
    @name = name
  end

  def to_s
    TaggedAddress.new(ENV.fetch('MAIL_REPLY')).tap do |address|
      address.tag = GIDTag.new(user, record).to_s
      address.display_name = name
    end.to_s
  end
end
