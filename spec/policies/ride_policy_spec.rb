require 'rails_helper'

describe RidePolicy do
  describe RidePolicy::Scope do
    describe '#resolve' do
      let!(:related_rides) { create_list(:ride, 4, car: user.cars.sample) }

      let!(:other_rides) { create_list(:ride, 2) }

      subject { RidePolicy::Scope.new(user, scope).resolve }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      let(:scope) { Ride.all }

      it { is_expected.to match_array(related_rides) }
    end
  end

  describe '#show?' do
    subject { RidePolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    let(:record) { create(:ride, car: car) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { RidePolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    let(:record) { build(:ride, car: car) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { RidePolicy.new(user, record).update? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    let(:record) { create(:ride, car: car) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }

      context 'who did the ride' do
        let(:record) { create(:ride, car: car, user: user) }

        it { is_expected.to be true }
      end
    end

    context 'as owner' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#destroy?' do
    subject { RidePolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    let(:record) { create(:ride, car: car) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }

      context 'who did the ride' do
        let(:record) { create(:ride, car: car, user: user) }

        it { is_expected.to be true }
      end
    end

    context 'as owner' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#accessible_associations' do
    subject { RidePolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { RidePolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) { %i(id distance started_at ended_at created_at updated_at) }

    it { is_expected.to match_array(attrs) }
  end

  describe '#permitted_attributes' do
    subject { RidePolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) { %i(distance started_at ended_at) }

    it { is_expected.to match_array(attrs) }
  end
end
