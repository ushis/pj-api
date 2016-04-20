require 'rails_helper'

describe ReplyAddress do
  describe '.decode' do
    context 'given a valid address' do
      subject { ReplyAddress.decode(address) }

      let(:address) { ReplyAddress.new(user, record, name).to_s }

      let(:user) { create(:user) }

      let(:record) { create(:car) }

      let(:name) { SecureRandom.hex(28) }

      its(:user) { is_expected.to eq(user) }

      its(:record) { is_expected.to eq(record) }

      its(:name) { is_expected.to eq(name) }
    end

    context 'given an invalid address' do
      let(:address) do
        TaggedAddress.new("#{SecureRandom.hex(6)}@example.com").tap do |addr|
          addr.tag = tag
        end.to_s
      end

      context 'with invalid syntax' do
        let(:address) { "#{SecureRandom.hex(28)}@" }

        it 'raises InvalidAddress' do
          expect { ReplyAddress.decode(address) }.to \
            raise_error(ReplyAddress::InvalidAddress)
        end
      end

      context 'with invalid signature' do
        let(:tag) { GIDTag.new(signer: signer).encode(user, record) }

        let(:signer) { MessageSigner.new(key: key) }

        let(:key) { SecureRandom.hex(128) }

        let(:user) { create(:user) }

        let(:record) { create(:car) }

        it 'raises InvalidAddress' do
          expect { ReplyAddress.decode(address) }.to \
            raise_error(ReplyAddress::InvalidAddress)
        end
      end

      context 'with invalid message' do
        let(:tag) { MessageSigner.new.sign(SecureRandom.hex(32)) }

        it 'raise InvalidAddress' do
          expect { ReplyAddress.decode(address) }.to \
            raise_error(ReplyAddress::InvalidAddress)
        end
      end

      context 'with destroyed records' do
        let!(:address) { ReplyAddress.new(user, record).to_s }

        let(:user) { create(:user) }

        let(:record) { create(:ride) }

        before { record.destroy }

        it 'raises ActiveRecord::RecordNotFound' do
          expect { ReplyAddress.decode(address) }.to \
            raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe '#to_s' do
    subject { TaggedAddress.new(address) }

    let(:address) { ReplyAddress.new(user, record, name).to_s }

    let(:user) { create(:user) }

    let(:record) { create(:reservation) }

    let(:name) { SecureRandom.hex(24) }

    let(:untagged) { Mail::Address.new(ENV.fetch('MAIL_REPLY')) }

    its(:display_name) { is_expected.to eq(name) }

    its(:tag) { is_expected.to be_present }

    its(:untagged_local) { is_expected.to eq(untagged.local) }

    its(:domain) { is_expected.to eq(untagged.domain) }
  end
end
