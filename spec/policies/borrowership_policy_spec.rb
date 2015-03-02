require 'rails_helper'

describe BorrowershipPolicy do
  describe BorrowershipPolicy::Scope do
    describe '#resolve' do
      let!(:related_borrowerships) { create_list(:borrowership, 2, car: car) }

      let!(:unrelated_borrowerships) { create_list(:borrowership, 2) }

      subject { BorrowershipPolicy::Scope.new(user, scope).resolve }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      let(:scope) { Borrowership.all }

      context 'as unrelated user' do
        let(:car) { create(:car) }

        it { is_expected.to match_array(user.borrowerships) }
      end

      context 'as related user' do
        let(:car) { user.borrowed_cars.sample }

        let(:all) { related_borrowerships + user.borrowerships }

        it { is_expected.to match_array(all) }
      end
    end
  end

  describe '#show?' do
    subject { BorrowershipPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:borrowership) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:borrowership, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { BorrowershipPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { build(:borrowership) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:record) { build(:borrowership, car: user.borrowed_cars.sample) }

      it { is_expected.to be false }
    end

    context 'as owner' do
      let(:record) { build(:borrowership, car: user.owned_cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { BorrowershipPolicy.new(user, record).update? }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to be false }
  end

  describe '#destroy?' do
    subject { BorrowershipPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:borrowership) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:record) { create(:borrowership, car: user.borrowed_cars.sample) }

      it { is_expected.to be false }

      context 'given her own borrowership' do
        let(:record) { user.borrowerships.sample }

        it { is_expected.to be true }
      end
    end

    context 'as owner' do
      let(:record) { create(:borrowership, car: user.owned_cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#accessible_associations' do
    subject { BorrowershipPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { BorrowershipPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:id, :created_at, :updated_at]) }
  end

  describe '#permitted_attributes' do
    subject { BorrowershipPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user_id]) }
  end
end
