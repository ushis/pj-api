require 'rails_helper'

describe RideComment do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:ride).inverse_of(:comments) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user).on(:create) }
    it { is_expected.to validate_presence_of(:ride) }
    it { is_expected.to validate_presence_of(:comment) }
  end
end
