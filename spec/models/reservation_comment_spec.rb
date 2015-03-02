require 'rails_helper'

describe ReservationComment do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reservation).inverse_of(:comments) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user).on(:create) }
    it { is_expected.to validate_presence_of(:reservation) }
    it { is_expected.to validate_presence_of(:comment) }
  end
end
