require 'rails_helper'

describe UserPolicy do
  describe UserPolicy::Scope do
    describe '#resolve' do
      let!(:users) { create_list(:user, 3) }

      subject { UserPolicy::Scope.new(user, scope).resolve }

      let(:user) { nil }

      let(:scope) { User.all }

      it { is_expected.to match_array(users) }
    end
  end

  describe '#show?' do
    subject { UserPolicy.new(user, record).show? }

    let(:user) { nil }

    let(:record) { create(:user) }

    it { is_expected.to be true }
  end

  describe '#create?' do
    subject { UserPolicy.new(user, record).create? }

    let(:user) { nil }

    let(:record) { create(:user) }

    it { is_expected.to be true }
  end

  describe '#update?' do
    subject { UserPolicy.new(user, record).update? }

    let(:record) { create(:user) }

    context 'user is not record' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end

    context 'user is record' do
      let(:user) { record }

      it { is_expected.to be true }
    end
  end

  describe '#accessible_associations' do
    subject { UserPolicy.new(user, record).accessible_associations }

    let(:user) { record }

    let(:record) { create(:user) }

    it { is_expected.to eq([]) }
  end

  describe '#accessible_attributes' do
    subject { UserPolicy.new(user, record).accessible_attributes }

    let(:record) { create(:user) }

    context 'user is no record' do
      let(:user) { create(:user) }

      it { is_expected.to match_array([:id, :username]) }
    end

    context 'user is record' do
      let(:user) { record }

      let(:attrs) { %i(id username email created_at updated_at access_token) }

      it { is_expected.to match_array(attrs) }
    end
  end

  describe '#permitted_attributes' do
    subject { UserPolicy.new(user, record).permitted_attributes }

    let(:user) { record }

    context 'record is persisted' do
      let(:record) { create(:user) }

      let(:attrs) { %i(email password password_confirmation) }

      it { is_expected.to match_array(attrs) }
    end

    context 'record is not persisted' do
      let(:record) { build(:user) }

      let(:attrs) { %i(username email password password_confirmation) }

      it { is_expected.to match_array(attrs) }
    end
  end
end
