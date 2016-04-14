class ReplyAddress < Struct.new(:user, :record)
  class InvalidAddress < StandardError; end

  GID_SEPARATOR = '|'

  class Encoder < Struct.new(:user, :record)

    def to_s
      TaggedAddress.new(reply_address).tap do |addr|
        addr.tag = tag
        addr.display_name = name
      end.to_s
    end

    private

    def tag
      MessageSigner.new.sign(gids.join(GID_SEPARATOR))
    end

    def name
      record.car.name
    end

    def gids
      [user.to_gid.to_s, record.to_gid.to_s]
    end

    def reply_address
      ENV.fetch('MAIL_REPLY')
    end
  end

  class Decoder < Struct.new(:address)

    def records
      gids.map { |gid| GlobalID.new(gid).find }
    end

    private

    def gids
      tag.split(GID_SEPARATOR)
    end

    def tag
      MessageSigner.new.verify(TaggedAddress.new(address).tag.to_s)
    rescue MessageSigner::InvalidMessage, Mail::Field::ParseError
      raise InvalidAddress
    end
  end

  def self.decode(address)
    new(*Decoder.new(address).records)
  end

  def to_s
    Encoder.new(user, record).to_s
  end
end
