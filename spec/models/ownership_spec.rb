require 'rails_helper'

describe Ownership do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:ownerships) }
    it { is_expected.to belong_to(:car).inverse_of(:ownerships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user).with_message('must exist') }
    it { is_expected.to validate_presence_of(:car).with_message('must exist') }

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

  describe '.order_by_attribute_values' do
    subject { Ownership.order_by_attribute_values.keys }

    let(:attrs) { %w(id created_at updated_at user.username) }

    it { is_expected.to match_array(attrs) }
  end

  describe '.order_by' do
    let!(:ownerships) { create_list(:ownership, 3) }

    subject { Ownership.order_by(attr, direction) }

    let(:result) do
      ownerships.sort do |a, b|
        if direction == :desc
          b.send(attr) <=> a.send(attr)
        else
          a.send(attr) <=> b.send(attr)
        end
      end
    end

    [:id, :created_at, :updated_at].each do |attribute|
      context "attr is #{attribute}" do
        let(:attr) { attribute }

        context 'direction is asc' do
          let(:direction) { :asc }

          it { is_expected.to eq(result) }
        end

        context 'direction is asc' do
          let(:direction) { :desc }

          it { is_expected.to eq(result) }
        end
      end
    end

    context "attr is 'user.username'" do
      let(:attr) { 'user.username' }

      let(:result) do
        ownerships.sort do |a, b|
          if direction == :desc
            b.user.username <=> a.user.username
          else
            a.user.username <=> b.user.username
          end
        end
      end

      context 'direction is asc' do
        let(:direction) { :asc }

        it { is_expected.to eq(result) }
      end

      context 'direction is asc' do
        let(:direction) { :desc }

        it { is_expected.to eq(result) }
      end
    end

    context 'attr is something else' do
      let(:attr) { :user_id }

      let(:direction) { :asc }

      it 'does nothing' do
        expect(subject.order_values).to be_empty
      end
    end
  end
end
