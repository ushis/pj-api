require 'rails_helper'

describe Borrowership do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:borrowerships) }
    it { is_expected.to belong_to(:car).inverse_of(:borrowerships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:car) }

    describe 'uniqueness validations' do
      before { create(:borrowership) }

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
    subject { Borrowership.order_by_attribute_values }

    let(:attrs) do
      {
        'id' => :id,
        'created_at' => :created_at,
        'user.username' => [:user, :username]
      }
    end

    it { is_expected.to eq(attrs) }
  end

  describe '.order_by' do
    let!(:borrowerships) { create_list(:borrowership, 3) }

    subject { Borrowership.order_by(attr, direction) }

    let(:result) do
      borrowerships.sort do |a, b|
        if direction == :desc
          b.send(attr) <=> a.send(attr)
        else
          a.send(attr) <=> b.send(attr)
        end
      end
    end

    [:id, :created_at].each do |attribute|
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

    context "attr is user.username" do
      let(:attr) { 'user.username' }

      let(:result) do
        borrowerships.sort do |a, b|
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
      let(:attr) { :updated_at }

      let(:direction) { :asc }

      it 'does nothing' do
        expect(subject.order_values).to be_empty
      end
    end
  end

end
