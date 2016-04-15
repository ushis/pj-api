require 'rails_helper'

describe ReplyPolicy do
  describe '#create?' do
    subject { ReplyPolicy.new(user, reply).create? }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let(:reply) { Reply.new(user, record, message) }

    let(:message) { SecureRandom.hex(32) }

    context 'when record is a car' do
      context 'as unrelated user' do
        let(:record) { build(:car) }

        it { is_expected.to be false }
      end

      context 'as related user' do
        let(:record) { user.cars.sample }

        it { is_expected.to be true }
      end
    end

    context 'when record is a ride' do
      context 'as unrelated user' do
        let(:record) { build(:ride) }

        it { is_expected.to be false }
      end

      context 'as related user' do
        let(:record) { create(:ride, car: user.cars.sample) }

        it { is_expected.to be true }
      end
    end

    context 'when record is a reservation' do
      context 'as unrelated user' do
        let(:record) { build(:reservation) }

        it { is_expected.to be false }
      end

      context 'as related user' do
        let(:record) { create(:reservation, car: user.cars.sample) }

        it { is_expected.to be true }
      end
    end
  end
end
