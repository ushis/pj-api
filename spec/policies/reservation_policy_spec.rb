require 'rails_helper'

describe ReservationPolicy do
  it { is_expected.to be_a(ApplicationPolicy) }

  describe '#show?' do
    subject { ReservationPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { create(:reservation, car: car) }

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
    subject { ReservationPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { build(:reservation, car: car) }

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
    subject { ReservationPolicy.new(user, record).update? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { create(:reservation, car: car) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }

      context 'who did the reservation' do
        let(:record) { create(:reservation, car: car, user: user) }

        it { is_expected.to be true }
      end
    end

    context 'as owner' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#destroy?' do
    subject { ReservationPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { create(:reservation, car: car) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }

      context 'who did the reservation' do
        let(:record) { create(:reservation, car: car, user: user) }

        it { is_expected.to be true }
      end
    end

    context 'as owner' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#accessible_associations' do
    subject { ReservationPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { ReservationPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) { %i(id starts_at ends_at created_at updated_at) }

    it { is_expected.to match_array(attrs) }
  end

  describe '#permitted_attributes' do
    subject { ReservationPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:starts_at, :ends_at]) }
  end
end
