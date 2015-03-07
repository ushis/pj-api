require 'rails_helper'

describe ApplicationPolicy do
  describe '#show?' do
    subject { ApplicationPolicy.new(nil, nil).show? }

    it { is_expected.to be false }
  end

  describe '#create?' do
    subject { ApplicationPolicy.new(nil, nil).create? }

    it { is_expected.to be false }
  end

  describe '#update?' do
    subject { ApplicationPolicy.new(nil, nil).update? }

    it { is_expected.to be false }
  end

  describe '#destroy?' do
    subject { ApplicationPolicy.new(nil, nil).destroy? }

    it { is_expected.to be false }
  end

  describe '#accessible_associations' do
    subject { ApplicationPolicy.new(nil, nil).accessible_associations }

    it { is_expected.to eq([]) }
  end

  describe '#accessible_attributes' do
    subject { ApplicationPolicy.new(nil, nil).accessible_attributes }

    it { is_expected.to eq([]) }
  end

  describe '#permitted_attributes' do
    subject { ApplicationPolicy.new(nil, nil).permitted_attributes }

    it { is_expected.to eq([]) }
  end
end
