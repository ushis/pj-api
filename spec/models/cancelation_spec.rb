require 'rails_helper'

describe Cancelation do
  describe 'associations' do
    it { is_expected.to belong_to(:reservation).inverse_of(:cancelation) }
    it { is_expected.to belong_to(:user).inverse_of(:cancelations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:reservation).with_message('must exist') }
    it { is_expected.to_not validate_presence_of(:user).with_message('must_exist') }
  end
end
