require 'rails_helper'

describe CarPolicy do
  it { is_expected.to be_a(ApplicationPolicy) }

  describe '#show?' do
    subject { CarPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { user.cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { CarPolicy.new(user, record).create? }

    let(:user) { create(:user) }

    context 'as unrelated user' do
      let(:record) { build(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:record) { user.borrowed_cars.build }

      it { is_expected.to be false }
    end

    context 'as owner' do
      let(:record) { user.owned_cars.build }

      it { is_expected.to be true }
    end
  end

  describe 'update?' do
    subject { CarPolicy.new(user, record).update? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:record) { user.borrowed_cars.sample }

      it { is_expected.to be false }
    end

    context 'as owner' do
      let(:record) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe 'update?' do
    subject { CarPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:car) }

      it { is_expected.to be false }
    end

    context 'as borrower' do
      let(:record) { user.borrowed_cars.sample }

      it { is_expected.to be false }
    end

    context 'as owner' do
      let(:record) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe 'accessible_associations' do
    subject { CarPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:location]) }
  end

  describe 'accessible_attributes' do
    subject { CarPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) do
      %i(
          id name mileage current_user
          rides_count owners_count borrowers_count comments_count
          created_at updated_at
        )
    end

    it { is_expected.to match_array(attrs) }
  end

  describe 'permitted_attributes' do
    subject { CarPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:name]) }
  end
end
