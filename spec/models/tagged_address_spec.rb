require 'rails_helper'

describe TaggedAddress do
  describe '#untagged_local' do
    subject { TaggedAddress.new(address).untagged_local }

    let(:address) { "#{local}@example.com" }

    context 'for untagged address' do
      let(:local) { SecureRandom.uuid }

      it { is_expected.to eq(local) }
    end

    context 'for tagged address' do
      let(:local) { "#{untagged}+#{SecureRandom.uuid}" }

      let(:untagged) { SecureRandom.uuid }

      it { is_expected.to eq(untagged) }
    end

    context 'without an address' do
      let(:address) { nil }

      it { is_expected.to eq(nil) }
    end
  end

  describe '#tag' do
    subject { TaggedAddress.new(address).tag }

    let(:address) { "#{local}@example.com" }

    context 'for untagged address' do
      let(:local) { SecureRandom.uuid }

      it { is_expected.to eq(nil) }
    end

    context 'for tagged address' do
      let(:local) { "#{SecureRandom.uuid}+#{tag}" }

      let(:tag) { SecureRandom.uuid }

      it { is_expected.to eq(tag) }
    end

    context 'without an address' do
      let(:address) { nil }

      it { is_expected.to eq(nil) }
    end
  end

  describe '#tag=' do
    before { tagged_address.tag = tag }

    subject { tagged_address.to_s }

    let(:tagged_address) { TaggedAddress.new(address) }

    let(:address) { "#{name} <#{local}@example.com>" }

    let(:name) { [SecureRandom.uuid, SecureRandom.uuid].join(' ') }

    context 'for untagged address' do
      let(:local) { SecureRandom.uuid }

      context 'given tag is present' do
        let(:tag) { SecureRandom.uuid }

        it { is_expected.to eq("#{name} <#{local}+#{tag}@example.com>") }
      end

      context 'given tag is blank' do
        let(:tag) { '  ' }

        it { is_expected.to eq(address) }
      end
    end

    context 'for tagged address' do
      let(:local) { "#{untagged}+#{SecureRandom.uuid}" }

      let(:untagged) { SecureRandom.uuid }

      context 'given tag is present' do
        let(:tag) { SecureRandom.uuid }

        it { is_expected.to eq("#{name} <#{untagged}+#{tag}@example.com>") }
      end

      context 'given tag is blank' do
        let(:tag) { '  ' }

        it { is_expected.to eq("#{name} <#{untagged}@example.com>") }
      end
    end
  end

  describe '#local=' do
    before { tagged_address.local = new_local }

    subject { tagged_address.to_s }

    let(:tagged_address) { TaggedAddress.new(address) }

    let(:address) { domain.blank? ? local : "#{local}@#{domain}" }

    let(:local) { SecureRandom.uuid }

    let(:new_local) { SecureRandom.uuid }

    context 'when domain is present' do
      let(:domain) { "#{SecureRandom.uuid}.com" }

      it { is_expected.to eq("#{new_local}@#{domain}") }
    end

    context 'when domain is blank' do
      let(:domain) { nil }

      it { is_expected.to eq(new_local) }
    end

    context 'when address is missing' do
      let(:address) { nil }

      it { is_expected.to eq(new_local) }
    end
  end
end
