class ReplyAddress
  class InvalidAddress < StandardError; end

  attr_reader :user, :record, :name

  def self.decode(address)
    addr = TaggedAddress.new(address)
    name = addr.display_name
    user, record = GIDTag.new.decode(addr.tag.to_s)
    new(user, record, name)
  rescue GIDTag::InvalidTag, Mail::Field::ParseError
    raise InvalidAddress
  end

  def initialize(user, record, name=nil)
    @user = user
    @record = record
    @name = name
  end

  def address
    tagged_address.address
  end

  def to_s
    tagged_address.to_s
  end

  private

  def tagged_address
    TaggedAddress.new(ENV.fetch('MAIL_REPLY')).tap do |address|
      address.tag = GIDTag.new.encode(user, record)
      address.display_name = name
    end
  end
end
