class GIDTag
  class InvalidTag < StandardError; end

  GID_SEPARATOR = '|'

  class Encoder

    def initialize(options={})
      @signer = options[:signer] || MessageSigner.new
    end

    def encode(records)
      @signer.sign(gids(records).join(GID_SEPARATOR))
    end

    private

    def gids(records)
      records.map { |record| record.to_gid.to_s }
    end
  end

  class Decoder

    def initialize(options={})
      @signer = options[:signer] || MessageSigner.new
    end

    def decode(tag)
      gids(tag).map { |gid| GlobalID.new(gid).find }
    rescue URI::BadURIError
      raise InvalidTag
    end

    private

    def gids(tag)
      @signer.verify(tag).split(GID_SEPARATOR)
    rescue MessageSigner::InvalidMessage
      raise InvalidTag
    end
  end

  def initialize(options={})
    @options = options
  end

  def encode(*records)
    Encoder.new(@options).encode(records)
  end

  def decode(tag)
    Decoder.new(@options).decode(tag)
  end
end
