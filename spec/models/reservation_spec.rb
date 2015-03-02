require 'rails_helper'

describe Reservation do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:reservations) }
    it { is_expected.to belong_to(:car).inverse_of(:reservations) }

    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:car) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }

    describe 'starts_at before ends_at' do
      subject { build(:reservation, starts_at: starts_at, ends_at: ends_at) }

      before { subject.valid? }

      context 'starts_at is before ends_at' do
        let(:starts_at) { 1.day.from_now }

        let(:ends_at) { 3.days.from_now }

        it { is_expected.to be_valid }
      end

      context 'starts_at is after ends_at' do
        let(:starts_at) { 3.days.from_now }

        let(:ends_at) { 1.day.from_now }

        it { is_expected.to_not be_valid }

        it 'has an error' do
          expect(subject.errors[:ends_at]).to be_present
        end
      end

      context 'starts_at equals ends_at' do
        let(:starts_at) { 1.days.ago }

        let(:ends_at) { starts_at }

        it { is_expected.to_not be_valid }

        it 'has an error' do
          expect(subject.errors[:ends_at]).to be_present
        end
      end
    end
  end
end
