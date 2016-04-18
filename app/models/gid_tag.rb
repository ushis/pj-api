class GIDTag
  class InvalidTag < StandardError; end

  GID_SEPARATOR = '|'

  class Encoder < Struct.new(:records)

    def to_s
      MessageSigner.new.sign(gids.join(GID_SEPARATOR))
    end

    private

    def gids
      records.map { |record| record.to_gid.to_s }
    end
  end

  class Decoder < Struct.new(:tag)

    def records
      gids.map { |gid| GlobalID.new(gid).find }
    rescue MessageSigner::InvalidMessage, URI::BadURIError
      raise InvalidTag
    end

    private

    def gids
      MessageSigner.new.verify(tag).split(GID_SEPARATOR)
    end
  end

  attr_reader :records

  def self.decode(tag)
    new(*Decoder.new(tag).records)
  end

  def initialize(*records)
    @records = records
  end

  def to_s
    Encoder.new(records).to_s
  end
end
