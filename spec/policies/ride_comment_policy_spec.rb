require 'rails_helper'

describe RideCommentPolicy do
  it { is_expected.to be_a(ApplicationPolicy) }

  describe '#show?' do
    subject { RideCommentPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:ride_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:ride_comment, ride: ride) }

      let(:ride) { create(:ride, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { RideCommentPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { build(:ride_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { build(:ride_comment, ride: ride) }

      let(:ride) { create(:ride, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { RideCommentPolicy.new(user, record).update? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:ride_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      let(:ride) { create(:ride, car: car) }

      context 'who did not write the comment' do
        let(:record) { create(:ride_comment, ride: ride) }

        it { is_expected.to be false }
      end

      context 'who wrote the comment' do
        let(:record) do
          create(:ride_comment, ride: ride, user: user, created_at: created_at)
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
    subject { RideCommentPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:ride_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      let(:ride) { create(:ride, car: car) }

      context 'who did not write the comment' do
        let(:record) { create(:ride_comment, ride: ride) }

        it { is_expected.to be false }
      end

      context 'who wrote the comment' do
        let(:record) do
          create(:ride_comment, ride: ride, user: user, created_at: created_at)
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
    subject { RideCommentPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { RideCommentPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) { %i(id comment created_at updated_at) }

    it { is_expected.to match_array(attrs) }
  end

  describe '#permitted_attributes' do
    subject { RideCommentPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:comment]) }
  end
end
