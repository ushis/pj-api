require 'rails_helper'

describe CarComment do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:car).inverse_of(:comments) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user).on(:create) }
    it { is_expected.to validate_presence_of(:car) }
    it { is_expected.to validate_presence_of(:comment) }
  end
end
