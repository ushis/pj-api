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

  describe '.order_by_attribute_values' do
    subject { Car.order_by_attribute_values }

    let(:attrs) do
      {
        'id' => :id,
        'name' => :name,
        'created_at' => :created_at
      }
    end

    it { is_expected.to eq(attrs) }
  end

  describe '.order_by' do
    let!(:cars) { create_list(:car, 3) }

    subject { Car.order_by(attr, direction) }

    let(:result) do
      cars.sort do |a, b|
        if direction == :desc
          b.send(attr) <=> a.send(attr)
        else
          a.send(attr) <=> b.send(attr)
        end
      end
    end

    [:id, :name, :created_at].each do |attribute|
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

  describe '#owned_by?' do
    subject { car.owned_by?(user) }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'the car is not related to the user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'the car is borrowed by the user' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }
    end

    context 'the car is owned by the user' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#borrowed_by?' do
    subject { car.borrowed_by?(user) }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'the car is not related to the user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'the car is borrowed by the user' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be true }
    end

    context 'the car is owned by the user' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be false }
    end
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
