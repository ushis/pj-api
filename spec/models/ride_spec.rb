require 'rails_helper'

describe Ride do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:rides) }
    it { is_expected.to belong_to(:car).inverse_of(:rides).counter_cache(true) }

    it { is_expected.to have_many(:comments).dependent(:destroy).counter_cache(:comments_count) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:car) }
    it { is_expected.to validate_presence_of(:distance) }
    it { is_expected.to validate_presence_of(:started_at) }
    it { is_expected.to validate_presence_of(:ended_at) }
    it { is_expected.to validate_numericality_of(:distance).is_greater_than(0) }

    describe 'started_at before ended_at'do
      subject { build(:ride, started_at: started_at, ended_at: ended_at) }

      before { subject.valid? }

      context 'started_at is before ended_at' do
        let(:started_at) { 3.days.ago }

        let(:ended_at) { 1.day.ago }

        it { is_expected.to be_valid }
      end

      context 'started_at is after ended_at' do
        let(:started_at) { 1.days.ago }

        let(:ended_at) { 3.day.ago }

        it { is_expected.to_not be_valid }

        it 'has an error' do
          expect(subject.errors[:ended_at]).to be_present
        end
      end

      context 'started_at equals ended_at' do
        let(:started_at) { 1.days.ago }

        let(:ended_at) { started_at }

        it { is_expected.to_not be_valid }

        it 'has an error' do
          expect(subject.errors[:ended_at]).to be_present
        end
      end
    end
  end

  describe 'after_save callbacks' do
    describe ':update_car_mileage' do
      let(:ride) { build(:ride, car: car) }

      let(:car) { create(:car, :with_rides) }

      it 'updates the cars mileage' do
        expect { ride.save }.to change { car.reload.mileage }.by(ride.distance)
      end
    end
  end

  describe 'after_destroy callbacks' do
    describe ':update_car_mileage' do
      let(:ride) { car.rides.sample }

      let(:car) { create(:car, :with_rides) }

      it 'updates the cars mileage' do
        expect {
          ride.destroy
        }.to change {
          car.reload.mileage
        }.by(-1 * ride.distance)
      end
    end
  end

  describe '.before' do
    let!(:older) do
      create(:ride, started_at: date - 3.days, ended_at: date + 1.day)
    end

    let!(:same) do
      create(:ride, started_at: date, ended_at: date + 1.day)
    end

    let!(:younger) do
      create(:ride, started_at: date + 3.days, ended_at: date + 4.days)
    end

    subject { Ride.before(date) }

    let(:date) { 1.day.ago }

    it { is_expected.to match_array([older]) }
  end

  describe '.after' do
    let!(:older) do
      create(:ride, started_at: date - 3.days, ended_at: date - 1.day)
    end

    let!(:same) do
      create(:ride, started_at: date - 1.day, ended_at: date)
    end

    let!(:younger) do
      create(:ride, started_at: date + 3.days, ended_at: date + 4.days)
    end

    subject { Ride.after(date) }

    let(:date) { 3.days.ago }

    it { is_expected.to match_array([younger]) }
  end

  describe '.order_by_attribute_values' do
    subject { Ride.order_by_attribute_values }

    let(:attrs) { %w(id distance started_at ended_at created_at).to_set }

    it { is_expected.to eq(attrs) }
  end

  describe '.order_by' do
    let!(:rides) { create_list(:ride, 3) }

    subject { Ride.order_by(attr, direction) }

    let(:result) do
      rides.sort do |a, b|
        if direction == :desc
          b.send(attr) <=> a.send(attr)
        else
          a.send(attr) <=> b.send(attr)
        end
      end
    end

    [:id, :distance, :started_at, :ended_at, :created_at].each do |attribute|
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
      let(:attr) { :updated_at }

      let(:direction) { :asc }

      it 'does nothing' do
        expect(subject.order_values).to be_empty
      end
    end
  end
end
