require 'rails_helper'

describe PositionPolicy do
  describe '#show?' do
    subject { PositionPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:position) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:position, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { PositionPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { build(:position) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { build(:position, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { PositionPolicy.new(user, record).update? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:position) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:position, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#destroy?' do
    subject { PositionPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:position) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:position, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe 'accessible_associations' do
    subject { PositionPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to be_empty }
  end

  describe 'accessible_attributes' do
    subject { PositionPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) { %i(latitude longitude created_at updated_at) }

    it { is_expected.to match_array(attrs) }
  end

  describe 'permitted_attributes' do
    subject { PositionPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:latitude, :longitude]) }
  end
end
