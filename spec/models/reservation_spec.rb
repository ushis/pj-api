require 'rails_helper'

describe Reservation do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:reservations) }
    it { is_expected.to belong_to(:car).inverse_of(:reservations) }

    it { is_expected.to have_one(:cancelation).inverse_of(:reservation).dependent(:destroy) }

    it { is_expected.to have_many(:comments).dependent(:destroy).counter_cache(:comments_count) }
    it { is_expected.to have_many(:commenters).through(:comments).source(:user) }
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

  describe '.before' do
    let!(:older) do
      create(:reservation, starts_at: date - 3.days, ends_at: date + 1.day)
    end

    let!(:same) do
      create(:reservation, starts_at: date, ends_at: date + 1.day)
    end

    let!(:younger) do
      create(:reservation, starts_at: date + 3.days, ends_at: date + 4.days)
    end

    subject { Reservation.before(date) }

    let(:date) { 3.days.from_now }

    it { is_expected.to match_array([older]) }
  end

  describe '.after' do
    let!(:older) do
      create(:reservation, starts_at: date - 3.days, ends_at: date - 1.day)
    end

    let!(:same) do
      create(:reservation, starts_at: date - 1.day, ends_at: date)
    end

    let!(:younger) do
      create(:reservation, starts_at: date + 3.days, ends_at: date + 4.days)
    end

    subject { Reservation.after(date) }

    let(:date) { 1.day.from_now }

    it { is_expected.to match_array([younger]) }
  end

  describe '.order_by_attribute_values' do
    subject { Reservation.order_by_attribute_values.keys }

    let(:attrs) { %w(id starts_at ends_at created_at updated_at) }

    it { is_expected.to match_array(attrs) }
  end

  describe '.order_by' do
    let!(:reservations) { create_list(:reservation, 3) }

    subject { Reservation.order_by(attr, direction) }

    let(:result) do
      reservations.sort do |a, b|
        if direction == :desc
          b.send(attr) <=> a.send(attr)
        else
          a.send(attr) <=> b.send(attr)
        end
      end
    end

    [:id, :starts_at, :ends_at, :created_at, :updated_at].each do |attribute|
      context "attr is #{attribute}" do
        let(:attr) { attribute }

        context 'direction is asc' do
          let(:direction) { :asc }

          it { is_expected.to eq(result) }
        end

        context 'direction is asc' do
          let(:direction) { :desc }

          it { is_expected.to eq(result) }
        end
      end
    end

    context 'attr is something else' do
      let(:attr) { :user_id }

      let(:direction) { :asc }

      it 'does nothing' do
        expect(subject.order_values).to be_empty
      end
    end
  end

  describe '#cancelled?' do
    subject { reservation.cancelled? }

    let(:reservation) { create(:reservation) }

    it { is_expected.to be false }

    context 'with a cancelation' do
      before { create(:cancelation, reservation: reservation) }

      it { is_expected.to be true }
    end
  end
end
