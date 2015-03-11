require 'rails_helper'

describe ReservationComment do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reservation).inverse_of(:comments).counter_cache(:comments_count) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user).on(:create) }
    it { is_expected.to validate_presence_of(:reservation) }
    it { is_expected.to validate_presence_of(:comment) }
  end

  describe '.order_by_attribute_values' do
    subject { RideComment.order_by_attribute_values.keys }

    it { is_expected.to match_array(%w(id created_at updated_at)) }
  end

  describe '.order_by' do
    let!(:comments) { create_list(:ride_comment, 3) }

    subject { RideComment.order_by(attr, direction) }

    let(:result) do
      comments.sort do |a, b|
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

    context 'attr is something else' do
      let(:attr) { :user_id }

      let(:direction) { :asc }

      it 'does nothing' do
        expect(subject.order_values).to be_empty
      end
    end
  end
end
