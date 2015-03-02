require 'rails_helper'

describe Ownership do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:ownerships) }
    it { is_expected.to belong_to(:car).inverse_of(:ownerships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:car) }

    describe 'uniqueness validations' do
      before { create(:ownership) }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:car_id) }
    end
  end

  describe '.search' do
    let(:jane) { create(:ownership, user: build(:user, username: :jane)) }

    let(:john) { create(:ownership, user: build(:user, username: :john)) }

    let(:lisa) { create(:ownership, user: build(:user, username: :lisa)) }

    let(:bill) { create(:ownership, user: build(:user, username: :bill)) }

    subject { Ownership.search(q) }

    context 'given nothing' do
      let(:q) { nil }

      it { is_expected.to match_array([jane, john, lisa, bill]) }
    end

    context 'given a partial match' do
      let(:q) { 'j' }

      it { is_expected.to match_array([jane, john]) }
    end

    context 'given another partial match' do
      let(:q) { 'is' }
    end
  end
end
