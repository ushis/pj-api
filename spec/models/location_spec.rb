require 'rails_helper'

describe Location do
  describe 'associations' do
    it { is_expected.to belong_to(:car).inverse_of(:location) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:car) }
    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }

    it { is_expected.to validate_numericality_of(:latitude).is_greater_than(-90).is_less_than(90) }
    it { is_expected.to validate_numericality_of(:longitude).is_greater_than(-180).is_less_than(180) }
  end
end
