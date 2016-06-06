require 'rails_helper'

describe CancelationPolicy do
  it { is_expected.to be_a(ApplicationPolicy) }

  describe '#show?' do
    subject { CancelationPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { create(:cancelation, reservation: reservation) }

    let(:reservation) { create(:reservation, car: car) }

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
    subject { CancelationPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { build(:cancelation, reservation: reservation) }

    let(:reservation) { create(:reservation, car: car, user: reservator) }

    let(:reservator) { create(:user) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }

      context 'who is reservator' do
        let(:reservator) { user }

        it { is_expected.to be true }
      end
    end

    context 'as owner' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#destroy?' do
    subject { CancelationPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:record) { build(:cancelation, reservation: reservation) }

    let(:reservation) { create(:reservation, car: car, user: reservator) }

    let(:reservator) { create(:user) }

    context 'as unrelated user' do
      let(:car) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }

      context 'who is reservator' do
        let(:reservator) { user }

        it { is_expected.to be true }
      end
    end

    context 'as owner' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#accessible_associations' do
    subject { CancelationPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { CancelationPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) do
      %i(created_at updated_at)
    end

    it { is_expected.to match_array(attrs) }
  end

  describe '#permitted_attributes' do
    subject { CancelationPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to eq([]) }
  end
end
