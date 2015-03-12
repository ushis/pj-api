require 'rails_helper'

describe User do
  it { is_expected.to have_secure_password }

  describe 'associations' do
    it { is_expected.to have_many(:locations).inverse_of(:user).dependent(:nullify) }
    it { is_expected.to have_many(:comments).inverse_of(:user).dependent(:nullify) }
    it { is_expected.to have_many(:rides).inverse_of(:user).dependent(:nullify) }
    it { is_expected.to have_many(:reservations).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:relationships).inverse_of(:user).dependent(:destroy) }
    it { is_expected.to have_many(:ownerships).inverse_of(:user) }
    it { is_expected.to have_many(:borrowerships).inverse_of(:user) }
    it { is_expected.to have_many(:cars).through(:relationships).source(:car) }
    it { is_expected.to have_many(:owned_cars).through(:ownerships).source(:car) }
    it { is_expected.to have_many(:borrowed_cars).through(:borrowerships).source(:car) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password).on(:create) }
    it { is_expected.to validate_length_of(:username).is_at_most(255) }
    it { is_expected.to validate_length_of(:email).is_at_most(255) }
    it { is_expected.to allow_value('my+valid.email@example.com').for(:email) }
    it { is_expected.to_not allow_value('me.example.com').for(:email) }

    context 'when password is present' do
      subject { build(:user, password: 'secret') }

      it { is_expected.to validate_confirmation_of(:password) }
      it { is_expected.to validate_presence_of(:password_confirmation) }
    end

    context 'when password is not present' do
      subject { build(:user, password: nil) }

      it { is_expected.to_not validate_presence_of(:password_confirmation) }
    end

    describe 'uniqueness validations' do
      before { create(:user) }

      it { is_expected.to validate_uniqueness_of(:username) }
      it { is_expected.to validate_uniqueness_of(:email) }
    end
  end

  describe 'before validation callbacks' do
    describe 'username' do
      subject { build(:user, username: username) }

      context 'is normalized' do
        let(:username) { 'test' }

        it 'does nothing' do
          expect { subject.valid? }.to_not change { subject.username }
        end
      end

      context 'is not normalized' do
        let(:username) { ' sTRangE  ' }

        it 'normalizes the username' do
          expect {
            subject.valid?
          }.to change {
            subject.username
          }.from(username).to('strange')
        end
      end
    end

    describe 'email' do
      subject { build(:user, email: email) }

      context 'is normalized' do
        let(:email) { 'test@example.com' }

        it 'does nothing' do
          expect { subject.valid? }.to_not change { subject.email }
        end
      end

      context 'is not normalized' do
        let(:email) { '  straNGe@example.com ' }

        it 'normalizes the email' do
          expect {
            subject.valid?
          }.to change {
            subject.email
          }.from(email).to('straNGe@example.com')
        end
      end
    end
  end

  describe '.find_by_username_or_email' do
    let!(:users) { create_list(:user, 3) }

    let(:sample) { users.sample }

    subject { User.find_by_username_or_email(username_or_email) }

    context 'given invalid input' do
      let(:username_or_email) { 'invalid' }

      it { is_expected.to be_nil }
    end

    context 'given a valid username' do
      let(:username_or_email) { sample.username }

      it { is_expected.to eq(sample) }
    end

    context 'given a valid email' do
      let(:username_or_email) { sample.email }

      it { is_expected.to eq(sample) }
    end
  end

  describe '.search' do
    let!(:jane) { create(:user, username: :jane) }

    let!(:john) { create(:user, username: :john) }

    let!(:lisa) { create(:user, username: :lisa) }

    let!(:bill) { create(:user, username: :bill) }

    subject { User.search(q) }

    context 'given nothing' do
      let(:q) { nil }

      it { is_expected.to match_array([jane, john, lisa, bill]) }
    end

    context 'given a partial match' do
      let(:q) { 'j' }

      it { is_expected.to match_array([jane, john]) }
    end

    context 'given another partial match' do
      let(:q) { 'is' }

      it { is_expected.to match_array([lisa]) }
    end

    context 'given no match' do
      let(:q) { 'joe' }

      it { is_expected.to be_empty }
    end
  end

  describe '.exclude' do
    let!(:users) { create_list(:user, 5) }

    let(:samples) { users.sample(2) }

    subject { User.exclude(*exclude) }

    context 'given no arguments' do
      let(:exclude) { [] }

      it { is_expected.to match_array(users) }
    end

    context 'given two users' do
      let(:exclude) { samples }

      it { is_expected.to match_array(users - samples) }
    end
  end

  describe '.find_by_access_token' do
    subject { User.find_by_access_token(token) }

    let!(:user) { create(:user) }

    context 'given a valid token' do
      let(:token) { user.access_token }

      it { is_expected.to eq(user) }
    end

    context 'given an expired token' do
      let(:token) do
        User.tokens[:access].new(user.id, :access, 1.day.ago.to_i).to_s
      end

      it { is_expected.to be_nil }
    end

    context 'given an invalid scope' do
      let(:token) do
        User.tokens[:access].new(user.id, :invalid, 1.day.from_now.to_i).to_s
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#access_token' do
    let(:token) { User.tokens[:access].from_s(user.access_token) }

    let(:user) { create(:user) }

    describe 'id' do
      subject { token.id }

      it { is_expected.to eq(user.id) }
    end

    describe 'scope' do
      subject { token.scope }

      it { is_expected.to eq('access') }
    end

    describe 'exp' do
      subject { token.exp }

      it { is_expected.to eq(1.week.from_now.to_i) }
    end
  end

  describe '#valid_access_token?' do
    subject { user.valid_access_token?(token) }

    let(:user) { create(:user) }

    context 'given an expired token' do
      let(:token) do
        User.tokens[:access].new(user.id, :access, 1.day.ago.to_i).to_s
      end

      it { is_expected.to be false }
    end

    context 'given an invalid scope' do
      let(:token) do
        User.tokens[:access].new(user.id, :invalid, 1.day.from_now.to_i).to_s
      end

      it { is_expected.to be false }
    end

    context 'given an invalid id' do
      let(:token) do
        User.tokens[:access].new(0, :invalid, 1.day.from_now.to_i).to_s
      end

      it { is_expected.to be false }
    end

    context 'given a valid token' do
      let(:token) { user.access_token }

      it { is_expected.to be true }
    end
  end

  describe '#time_zone=' do
    before { user.time_zone = arg }

    let(:user) { build(:user) }

    subject { user.send(:read_attribute, :time_zone) }

    context 'when arg is nil' do
      let(:arg) { nil }

      it { is_expected.to be_nil }
    end

    context 'when arg is somthing invalid' do
      let(:arg) { [1e12, 'invalid'].sample }

      it { is_expected.to eq(Time.zone.tzinfo.name) }
    end

    context 'when arg is a valid time zone' do
      let(:arg) { [zone.tzinfo.name, zone.utc_offset].sample }

      let(:zone) { ActiveSupport::TimeZone.all.sample }

      it { is_expected.to eq(zone.tzinfo.name) }
    end
  end

  describe '#time_zone' do
    subject { user.time_zone }

    let(:user) { build(:user) }

    before { user.send(:write_attribute, :time_zone, time_zone) }

    context 'when time zone is something invalid' do
      let(:time_zone) { [nil, 12e100].sample }

      it { is_expected.to eq(Time.zone) }
    end

    context 'when time_zone is a valid time zone' do
      let(:time_zone) { [zone.tzinfo.name, zone.utc_offset].sample }

      let(:zone) { ActiveSupport::TimeZone.all.sample }

      its(:utc_offset) { is_expected.to eq(zone.utc_offset) }
    end
  end

  describe '#owns_or_borrows?' do
    subject { user.owns_or_borrows?(car) }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let!(:unrelated) { create_list(:car, 2) }

    context 'given an unrelated car' do
      let(:car) { unrelated.sample }

      it { is_expected.to be false }
    end

    context 'given a borrowed car' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be true }
    end

    context 'given an owned car' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#owns?' do
    subject { user.owns?(car) }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let!(:unrelated) { create_list(:car, 2) }

    context 'given an unrelated car' do
      let(:car) { unrelated.sample }

      it { is_expected.to be false }
    end

    context 'given a borrowed car' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be false }
    end

    context 'given an owned car' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be true }
    end
  end

  describe '#borrows?' do
    subject { user.borrows?(car) }

    let(:user) { create(:user, :with_owned_and_borrowed_cars) }

    let!(:unrelated) { create_list(:car, 2) }

    context 'given an unrelated car' do
      let(:car) { unrelated.sample }

      it { is_expected.to be false }
    end

    context 'given a borrowed car' do
      let(:car) { user.borrowed_cars.sample }

      it { is_expected.to be true }
    end

    context 'given an owned car' do
      let(:car) { user.owned_cars.sample }

      it { is_expected.to be false }
    end
  end

  describe '#email_with_username' do
    subject { user.email_with_username }

    let(:user) { build(:user) }

    it { is_expected.to eq("#{user.username} <#{user.email}>") }
  end
end
