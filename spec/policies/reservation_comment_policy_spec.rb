require 'rails_helper'

describe ReservationCommentPolicy do
  describe ReservationCommentPolicy::Scope do
    describe '#resolve' do
      let!(:related_comments) { create_list(:reservation_comment, 2, reservation: reservation) }

      let!(:unrelated_comments) { create_list(:reservation_comment, 2) }

      subject { ReservationCommentPolicy::Scope.new(user, scope).resolve }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      let(:car) { user.cars.sample }

      let(:reservation) { create(:reservation, car: car) }

      let(:scope) { ReservationComment.all }

      it { is_expected.to match_array(related_comments) }
    end
  end

  describe '#show?' do
    subject { ReservationCommentPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:reservation_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:reservation_comment, reservation: reservation) }

      let(:reservation) { create(:reservation, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { ReservationCommentPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { build(:reservation_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { build(:reservation_comment, reservation: reservation) }

      let(:reservation) { create(:reservation, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { ReservationCommentPolicy.new(user, record).update? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:reservation_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      let(:reservation) { create(:reservation, car: car) }

      context 'who did not write the comment' do
        let(:record) { create(:reservation_comment, reservation: reservation) }

        it { is_expected.to be false }
      end

      context 'who wrote the comment' do
        let(:record) do
          create(:reservation_comment, reservation: reservation, user: user, created_at: created_at)
        end

        context 'more than 10 minutes ago' do
          let(:created_at) { (rand(100) + 11).minutes.ago }

          it { is_expected.to be false }
        end

        context 'less than 10 minutes ago' do
          let(:created_at) { rand(10).minutes.ago }

          it { is_expected.to be true }
        end
      end
    end
  end

  describe '#destroy?' do
    subject { ReservationCommentPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:reservation_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      let(:reservation) { create(:reservation, car: car) }

      context 'who did not write the comment' do
        let(:record) { create(:reservation_comment, reservation: reservation) }

        it { is_expected.to be false }
      end

      context 'who wrote the comment' do
        let(:record) do
          create(:reservation_comment, reservation: reservation, user: user, created_at: created_at)
        end

        context 'more than 10 minutes ago' do
          let(:created_at) { (rand(100) + 11).minutes.ago }

          it { is_expected.to be false }
        end

        context 'less than 10 minutes ago' do
          let(:created_at) { rand(10).minutes.ago }

          it { is_expected.to be true }
        end
      end
    end
  end

  describe '#accessible_associations' do
    subject { ReservationCommentPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { ReservationCommentPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) { %i(id comment created_at updated_at) }

    it { is_expected.to match_array(attrs) }
  end

  describe '#permitted_attributes' do
    subject { ReservationCommentPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:comment]) }
  end
end
