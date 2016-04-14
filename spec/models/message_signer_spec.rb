require 'rails_helper'

describe MessageSigner do
  describe MessageSigner::InvalidEncoding do
    it { is_expected.to be_a MessageSigner::InvalidMessage }
  end

  describe MessageSigner::InvalidSignature do
    it { is_expected.to be_a MessageSigner::InvalidMessage }
  end

  describe '#verify' do
    context 'given a valid message' do
      subject { MessageSigner.new.verify(signed_message) }

      let(:signed_message) { MessageSigner.new.sign(message) }

      context 'which is empty' do
        let(:message) { '' }

        it { is_expected.to eq(message) }
      end

      context 'which is present' do
        let(:message) { SecureRandom.hex(64) }

        it { is_expected.to eq(message) }
      end
    end

    context 'given an invalid message' do
      let(:subject) { MessageSigner.new }

      let(:valid) { MessageSigner.new.sign(message) }

      let(:message) { SecureRandom.hex(24) }

      context 'sign with an invalid key' do
        let(:invalid) { MessageSigner.new(key).sign(message) }

        let(:key) { SecureRandom.hex(128) }

        it 'raises InvalidBase64' do
          expect { subject.verify(invalid) }.to \
            raise_error(MessageSigner::InvalidSignature)
        end
      end

      context 'with invalid encoding' do
        let(:invalid) { valid.tap { |s| s[rand(s.length-1)] = '*' } }

        it 'raises InvalidBase64' do
          expect { subject.verify(invalid) }.to \
            raise_error(MessageSigner::InvalidEncoding)
        end
      end

      context 'with invalid signature' do
        let(:valid_prefix) { valid[0, (valid.length - (valid.length % 4))] }

        let(:invalid) { valid_prefix + MessageSigner.new.sign(message) }

        it 'raises InvalidBase64' do
          expect { subject.verify(invalid) }.to \
            raise_error(MessageSigner::InvalidSignature)
        end
      end
    end
  end
end
