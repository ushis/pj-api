require 'rails_helper'

describe OwnershipPolicy do
  describe OwnershipPolicy::Scope do
    describe '#resolve' do
      let!(:related_ownerships) { create_list(:ownership, 2, car: car) }

      let!(:unrelated_ownerships) { create_list(:ownership, 2) }

      subject { OwnershipPolicy::Scope.new(user, scope).resolve }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      let(:scope) { Ownership.all }

      context 'as unrelated user' do
        let(:car) { create(:car) }

        it { is_expected.to match_array(user.ownerships) }
      end

      context 'as related user' do
        let(:car) { user.borrowed_cars.sample }

        let(:all) { related_ownerships + user.ownerships }

        it { is_expected.to match_array(all) }
      end
    end
  end

  describe '#show?' do
    subject { OwnershipPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:ownership) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:ownership, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { OwnershipPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { build(:ownership) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:record) { build(:ownership, car: user.borrowed_cars.sample) }

      it { is_expected.to be false }
    end

    context 'as owner' do
      let(:record) { build(:ownership, car: user.owned_cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { OwnershipPolicy.new(user, record).update? }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to be false }
  end

  describe '#destroy?' do
    subject { OwnershipPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:ownership) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:record) { create(:ownership, car: user.borrowed_cars.sample) }

      it { is_expected.to be false }
    end

    context 'as owner' do
      let(:record) { create(:ownership, car: user.owned_cars.sample) }

      it { is_expected.to be true }

      context 'given her own ownership' do
        let(:record) { user.ownerships.sample }

        context 'which is the last one' do
          it { is_expected.to be false }
        end

        context 'which is not the last one' do
          before { create(:ownership, car: record.car) }

          it { is_expected.to be true }
        end
      end
    end
  end

  describe '#accessible_associations' do
    subject { OwnershipPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { OwnershipPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:id, :created_at, :updated_at]) }
  end

  describe '#permitted_attributes' do
    subject { OwnershipPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user_id]) }
  end
end
