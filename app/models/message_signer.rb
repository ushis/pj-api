class MessageSigner
  class InvalidMessage < StandardError; end
  class InvalidEncoding < InvalidMessage; end
  class InvalidSignature < InvalidMessage; end

  def initialize(key=nil)
    @key = key
  end

  def sign(message)
    encode(message + generate_signature(message))
  end

  def verify(message)
    msg, sig = split_signed_message(decode(message))

    if msg.nil? || sig.nil? || !compare(sig, generate_signature(msg))
      raise InvalidSignature
    end

    msg
  end

  private

  def split_signed_message(message)
    len = message.length - digest.length
    [message[0, len], message[len, digest.length]]
  end

  def compare(a, b)
    ActiveSupport::SecurityUtils.secure_compare(a, b)
  end

  def encode(message)
    Base64.urlsafe_encode64(message, padding: false)
  end

  def decode(message)
    Base64.urlsafe_decode64(message)
  rescue ArgumentError
    raise InvalidEncoding
  end

  def generate_signature(message)
    OpenSSL::HMAC.digest(digest, key, message)
  end

  def digest
    @digest ||= OpenSSL::Digest::SHA1.new
  end

  def key
    @key ||= Rails.application.secrets.secret_key_base
  end
end
