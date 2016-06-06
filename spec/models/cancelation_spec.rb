require 'rails_helper'

describe Cancelation do
  describe 'associations' do
    it { is_expected.to belong_to(:reservation).inverse_of(:cancelation) }
    it { is_expected.to belong_to(:user).inverse_of(:cancelations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reservation) }
  end
end
