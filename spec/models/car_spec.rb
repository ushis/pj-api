require 'rails_helper'

describe Car do
  describe 'associations' do
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:rides).inverse_of(:car).dependent(:destroy) }
    it { is_expected.to have_many(:reservations).inverse_of(:car).dependent(:destroy) }
    it { is_expected.to have_many(:relationships).inverse_of(:car).dependent(:destroy) }
    it { is_expected.to have_many(:ownerships).inverse_of(:car) }
    it { is_expected.to have_many(:borrowerships).inverse_of(:car) }
    it { is_expected.to have_many(:users).through(:relationships).source(:user) }
    it { is_expected.to have_many(:owners).through(:ownerships).source(:user) }
    it { is_expected.to have_many(:borrowers).through(:borrowerships).source(:user) }

    it { is_expected.to have_one(:position).inverse_of(:car).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end

  describe '#position!' do
    context 'with no position' do
      let(:car) { build(:car) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect { car.position! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with position' do
      let(:car) { build(:car, :with_position) }

      subject { car.position! }

      it { is_expected.to eq(car.position) }
    end
  end

  describe '#update_mileage' do
    before { car.update_attribute(:mileage, 0) }

    context 'with no rides' do
      let(:car) { create(:car) }

      it 'does nothing' do
        expect { car.update_mileage }.to_not change { car.mileage }
      end
    end

    context 'with rides' do
      let(:car) { create(:car, :with_rides) }

      let(:mileage) { car.rides.pluck(:distance).reduce(:+) }

      it 'updates the cars mileage' do
        expect {
          car.update_mileage
        }.to change {
          car.mileage
        }.from(0).to(mileage)
      end
    end
  end
end
