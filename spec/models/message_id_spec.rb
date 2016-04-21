require 'rails_helper'

describe MessageID do
  describe '#id' do
    subject { Mail::Address.new(id) }

    let(:id) { MessageID.new(car, *records).id }

    let(:car) { create(:car, name: 'Test Car') }

    let(:from) { Mail::Address.new(ENV.fetch('MAIL_FROM')) }

    context 'without additional records' do
      let(:records) { [] }

      its(:local) { is_expected.to eq("test-car-#{car.id}") }

      its(:domain) { is_expected.to eq(from.domain) }
    end

    context 'with records' do
      let(:records) { [user, ride] }

      let(:user) { create(:user) }

      let(:ride) { create(:ride) }

      its(:local) { is_expected.to eq("test-car-#{car.id}/user/#{user.id}/ride/#{ride.id}") }

      its(:domain) { is_expected.to eq(from.domain) }
    end

    context 'with records including a comment' do
      let(:records) { [ride, comment] }

      let(:ride) { create(:ride) }

      let(:comment) { create(:ride_comment) }

      its(:local) { is_expected.to eq("test-car-#{car.id}/ride/#{ride.id}/#{comment.id}") }

      its(:domain) { is_expected.to eq(from.domain) }
    end
  end

  describe '#to_s' do
    subject { message_id.to_s }

    let(:message_id) { MessageID.new(car, *records) }

    let(:car) { create(:car) }

    let(:records) { [create(:reservation), create(:reservation_comment)] }

    it { is_expected.to eq("<#{message_id.id}>") }
  end
end
