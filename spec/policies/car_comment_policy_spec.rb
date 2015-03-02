require 'rails_helper'

describe CarCommentPolicy do
  describe CarCommentPolicy::Scope do
    describe '#resolve' do
      let!(:related_comments) { create_list(:car_comment, 2, car: car) }

      let!(:unrelated_comments) { create_list(:car_comment, 2) }

      subject { CarCommentPolicy::Scope.new(user, scope).resolve }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      let(:car) { user.cars.sample }

      let(:scope) { CarComment.all }

      it { is_expected.to match_array(related_comments) }
    end
  end

  describe '#show?' do
    subject { CarCommentPolicy.new(user, record).show? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:car_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { create(:car_comment, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#create?' do
    subject { CarCommentPolicy.new(user, record).create? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { build(:car_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:record) { build(:car_comment, car: user.cars.sample) }

      it { is_expected.to be true }
    end
  end

  describe '#update?' do
    subject { CarCommentPolicy.new(user, record).update? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:car_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      context 'who did not write the comment' do
        let(:record) { create(:car_comment, car: car) }

        it { is_expected.to be false }
      end

      context 'who wrote the comment' do
        let(:record) do
          create(:car_comment, car: car, user: user, created_at: created_at)
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
    subject { CarCommentPolicy.new(user, record).destroy? }

    let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

    context 'as unrelated user' do
      let(:record) { create(:car_comment) }

      it { is_expected.to be false }
    end

    context 'as related user' do
      let(:car) { user.cars.sample }

      context 'who did not write the comment' do
        let(:record) { create(:car_comment, car: car) }

        it { is_expected.to be false }
      end

      context 'who wrote the comment' do
        let(:record) do
          create(:car_comment, car: car, user: user, created_at: created_at)
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
    subject { CarCommentPolicy.new(user, record).accessible_associations }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:user]) }
  end

  describe '#accessible_attributes' do
    subject { CarCommentPolicy.new(user, record).accessible_attributes }

    let(:user) { nil }

    let(:record) { nil }

    let(:attrs) { %i(id comment created_at updated_at) }

    it { is_expected.to match_array(attrs) }
  end

  describe '#permitted_attributes' do
    subject { CarCommentPolicy.new(user, record).permitted_attributes }

    let(:user) { nil }

    let(:record) { nil }

    it { is_expected.to match_array([:comment]) }
  end
end
