require 'rails_helper'

describe Ride do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:rides) }
    it { is_expected.to belong_to(:car).inverse_of(:rides).counter_cache(true) }

    it { is_expected.to have_many(:comments).dependent(:destroy) }
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
end
