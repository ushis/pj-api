require 'rails_helper'

describe V1::UsersController do
  describe 'GET #index' do
    before { set_auth_header(token) }

    let!(:users) { create_list(:user, 3) }

    before { get :index }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user) }

      it { is_expected.to respond_with(:success) }

      it 'responds with all users' do
        expect(json[:users]).to match_array(users_json(users + [user]))
      end
    end
  end

  describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show, params: {id: id} }

    let(:id) { other.id }

    let(:other) { create(:user) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user) }

      context 'with invalid id' do
        let(:id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'with valid id' do
        it { is_expected.to respond_with(:success) }

        it 'responds the user' do
          expect(json[:user]).to eq(user_json(other))
        end
      end
    end
  end
end
