require 'rails_helper'

describe Reply do
  describe '#comment' do
    subject { Reply.new(user, record, message).comment }

    let(:user) { build(:user) }

    let(:record) { build(:ride) }

    let(:message) { SecureRandom.hex(32) }

    it { is_expected.to be_a(RideComment) }

    its(:user) { is_expected.to eq(user) }

    its(:ride) { is_expected.to eq(record) }

    its(:comment) { is_expected.to eq(message) }
  end

  describe '#save' do
    subject { Reply.new(user, record, message) }

    let(:user) { create(:user) }

    let(:record) { create(:ride) }

    let(:message) { SecureRandom.hex(32) }

    it 'saves to comment' do
      expect {
        subject.save
      }.to change {
        subject.comment.persisted?
      }.from(false).to(true)
    end

    context 'with blank message' do
      let(:message) { '  ' }

      it 'does not save the comment' do
        expect {
          subject.save
        }.to_not change {
          subject.comment.persisted?
        }.from(false)
      end
    end
  end

  describe '#errors' do
    before { reply.save }

    subject { reply.errors }

    let(:reply) { Reply.new(user, record, message) }

    let(:user) { create(:user) }

    let(:record) { create(:ride) }

    let(:message) { SecureRandom.hex(32) }

    it { is_expected.to be_empty }

    context 'with blank message' do
      let(:message) { '  ' }

      it { is_expected.to be_present }

      it 'includes an error message' do
        expect(subject.get(:message)).to be_present
      end
    end
  end

  describe '#read_attribute_for_validation' do
    subject { reply.read_attribute_for_validation(arg) }

    let(:reply) { Reply.new(user, record, message) }

    let(:user) { build(:user) }

    let(:record) { build(:ride) }

    let(:message) { SecureRandom.hex(32) }


    [:user, :record, :message].each do |attr|
      context "given #{attr.inspect}" do
        let(:arg) { attr }

        it { is_expected.to eq(send(arg)) }
      end
    end
  end

  describe '.human_attribute_name' do
    subject { Reply.human_attribute_name(arg) }

    [:user, :record, :message].each do |attr|
      context "given #{attr.inspect}" do
        let(:arg) { attr }

        it { is_expected.to eq(arg) }
      end
    end
  end

  describe '.lookup_ancestors' do
    subject { Reply.lookup_ancestors }

    it { is_expected.to eq([Reply]) }
  end
end
