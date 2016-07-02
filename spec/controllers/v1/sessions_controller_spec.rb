require 'rails_helper'

describe V1::SessionsController do
  describe 'POST #create' do
    let!(:user) { create(:user) }

    before { post :create, params: params }

    context 'without params' do
      let(:params) { {} }

      it { is_expected.to respond_with(:unprocessable_entity) }
    end

    context 'with invalid username' do
      let(:params) do
        {
          user: {
            username: 'invalid',
            password: user.password
          }
        }
      end

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'with invalid password' do
      let(:params) do
        {
          user: {
            username: user.username,
            password: 'invalid'
          }
        }
      end

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'with valid credentials' do
      let(:params) do
        {
          user: {
            username: [user.username, user.email].sample,
            password: user.password
          }
        }
      end

      it { is_expected.to respond_with(:created) }

      it 'responds with the session data' do
        expect(json[:user]).to eq(session_json(user))
      end
    end
  end
end
