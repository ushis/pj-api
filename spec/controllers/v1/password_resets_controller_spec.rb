require 'rails_helper'

describe V1::PasswordResetsController do
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
            username: :invalid
          }
        }
      end

      it { is_expected.to respond_with(:not_found) }
    end

    context 'with valid username' do
      let(:params) do
        {
          user: {
            username: user.username
          }
        }
      end

      it { is_expected.to respond_with(:created) }

      it 'responds with nothing' do
        expect(response.body).to be_empty
      end

      describe 'emails' do
        subject { ActionMailer::Base.deliveries.first }

        its(:to) { is_expected.to eq([user.email]) }

        its(:subject) { is_expected.to include('password') }

        its(:body) { is_expected.to include(user.password_reset_token) }

        it 'sets the correct From Header' do
          expect(subject.header['From'].to_s).to eq(ENV['MAIL_FROM'])
        end
      end
    end
  end

  describe 'PATCH #update' do
    let!(:user) { create(:user)  }

    before { set_auth_header(token) }

    before { patch :update, params: params }

    context 'as anonymous user' do
      let(:token) { nil }

      let(:params) { {} }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'with invalid token' do
      let(:token) { user.access_token }

      let(:params) { {} }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'with valid token' do
      let(:token) { user.password_reset_token }

      context 'without params' do
        let(:params) { {} }

        it { is_expected.to respond_with(:unprocessable_entity) }
      end

      context 'with invalid password confirmation' do
        let(:params) do
          {
            user: {
              password: 'secret',
              password_confirmation: [nil, 'invalid'].sample
            }
          }
        end

        it { is_expected.to respond_with(:unprocessable_entity) }

        it 'responds with error details' do
          expect(json[:details][:password_confirmation]).to be_present
        end
      end

      context 'with valid params' do
        let(:params) do
          {
            user: {
              password: password,
              password_confirmation: password
            }
          }
        end

        let(:password) { SecureRandom.uuid }

        it { is_expected.to respond_with(:no_content) }

        it 'updates the users password' do
          expect(user.reload.authenticate(password)).to eq(user)
        end
      end
    end
  end
end
