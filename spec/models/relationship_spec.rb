require 'rails_helper'

describe Relationship do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:relationships) }
    it { is_expected.to belong_to(:car).inverse_of(:relationships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user).with_message('must exist') }
    it { is_expected.to validate_presence_of(:car).with_message('must exist') }

    describe 'uniqueness validations' do
      before { [create(:ownership), create(:borrowership)].sample }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:car_id) }
    end
  end
end
