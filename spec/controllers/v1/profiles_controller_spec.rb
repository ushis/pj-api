require 'rails_helper'

describe V1::ProfilesController do
  describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show }

    let(:user) { create(:user) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      it { is_expected.to respond_with(:success) }

      it 'responds with the user' do
        expect(json[:user]).to eq(profile_json(user))
      end
    end
  end

  describe 'POST #create' do
    before { post :create, params }

    context 'without params' do
      let(:params) { {} }

      it { is_expected.to respond_with(:unprocessable_entity) }
    end

    context 'with invalid username' do
      let(:params) do
        {
          user: {
            username: [nil, 'in.valid'].sample,
            email: 'john@example.com',
            password: 'secret',
            password_confirmation: 'secret'
          }
        }
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with error details' do
        expect(json[:details][:username]).to be_present
      end
    end

    context 'with duplicate username' do
      let(:params) do
        {
          user: {
            username: username,
            email: 'john@example.com',
            password: 'secret',
            password_confirmation: 'secret'
          }
        }
      end

      let(:username) { create(:user).username }

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with error details' do
        expect(json[:details][:username]).to be_present
      end
    end

    context 'with invalid email' do
      let(:params) do
        {
          user: {
            username: 'john',
            email: [nil, 'in.valid.com'].sample,
            password: 'secret',
            password_confirmation: 'secret'
          }
        }
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with error details' do
        expect(json[:details][:email]).to be_present
      end
    end

    context 'with duplicate email' do
      let(:params) do
        {
          user: {
            username: 'john',
            email: email,
            password: 'secret',
            password_confirmation: 'secret'
          }
        }
      end

      let(:email) { create(:user).email }

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with error details' do
        expect(json[:details][:email]).to be_present
      end
    end

    context 'without password' do
      let(:params) do
        {
          user: {
            username: 'john'
          }
        }
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with error details' do
        expect(json[:details][:password]).to be_present
      end
    end

    context 'with invalid password_confirmation' do
      let(:params) do
        {
          user: {
            username: 'john',
            password: 'secret',
            password_confirmation: [nil, 'seCreT'].sample
          }
        }
      end

      it { is_expected.to respond_with(:unprocessable_entity) }

      it 'responds with error details' do
        expect(json[:details][:password_confirmation]).to be_present
      end
    end

    context 'wit valid params' do
      let(:params) do
        {
          user: {
            username: 'john',
            email: 'john@example.com',
            password: 'secret',
            password_confirmation: 'secret'
          }
        }
      end

      let(:user) { User.find_by_username_or_email(params[:user][:email]) }

      it { is_expected.to respond_with(:created) }

      it 'responds with the user' do
        expect(json[:user]).to eq(profile_json(user))
      end

      it 'creates the user' do
        expect(user).to be_present
      end

      it 'sets the correct username' do
        expect(user.username).to eq(params[:user][:username])
      end

      it 'sets the correct email' do
        expect(user.email).to eq(params[:user][:email])
      end

      it 'set the correct password' do
        expect(user.authenticate(params[:user][:password])).to eq(user)
      end
    end
  end

  describe 'PATCH #update' do
    before { set_auth_header(token) }

    before { patch :update, params }

    let(:user) { create(:user) }

    let(:other) { create(:user) }

    context 'as anonymous user' do
      let(:token) { nil }

      let(:params) { {} }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      context 'without params' do
        let(:params) { {} }

        it { is_expected.to respond_with(:unprocessable_entity) }
      end

      context 'with invalid password' do
        let(:params) do
          {
            user: {
              password_current: [nil, 'invalid'].sample
            }
          }
        end

        it { is_expected.to respond_with(:unauthorized) }
      end

      context 'with valid password' do
        let(:password_current) { user.password }

        context 'with username' do
          let(:params) do
            {
              user: {
                username: 'john',
                password_current: password_current
              }
            }
          end

          let!(:username) { user.username }

          it { is_expected.to respond_with(:success) }

          it 'responds with the user' do
            expect(json[:user]).to eq(profile_json(user.reload))
          end

          it 'does not set the username' do
            expect(user.reload.username).to eq(username)
          end
        end

        context 'with invalid email' do
          let(:params) do
            {
              user: {
                email: [nil, 'invalid.com', other.email].sample,
                password_current: password_current
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:email]).to be_present
          end
        end

        context 'with valid email' do
          let(:params) do
            {
              user: {
                email: 'john@example.com',
                password_current: password_current
              }
            }
          end

          it { is_expected.to respond_with(:success) }

          it 'responds with the user' do
            expect(json[:user]).to eq(profile_json(user.reload))
          end

          it 'sets the new email' do
            expect(user.reload.email).to eq(params[:user][:email])
          end
        end

        context 'with new password' do
          let(:password) { 'secret' }

          context 'with invalid password confirmation' do
            let(:params) do
              {
                user: {
                  password: password,
                  password_confirmation: [nil, 'seCreT'].sample,
                  password_current: password_current
                }
              }
            end

            it { is_expected.to respond_with(:unprocessable_entity) }

            it 'responds with error details' do
              expect(json[:details][:password_confirmation]).to be_present
            end
          end

          context 'with valid password confirmation' do
            let(:params) do
              {
                user: {
                  password: password,
                  password_confirmation: password,
                  password_current: password_current
                }
              }
            end

            it { is_expected.to respond_with(:success) }

            it 'responds with the user' do
              expect(json[:user]).to eq(profile_json(user.reload))
            end

            it 'sets the new password' do
              expect(user.reload.authenticate(password)).to eq(user)
            end
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { set_auth_header(token) }

    before { delete :destroy, params }

    let(:user) { create(:user) }

    context 'as anonymous user' do
      let(:token) { nil }

      let(:params) { {} }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user'  do
      let(:token) { user.access_token }

      context 'without params' do
        let(:params) { {} }

        it { is_expected.to respond_with(:unprocessable_entity) }
      end

      context 'with invalid password' do
        let(:params) do
          {
            user: {
              password_current: [nil, 'invalid'].sample
            }
          }
        end

        it { is_expected.to respond_with(:unauthorized) }
      end

      context 'with valid password' do
        let(:params) do
          {
            user: {
              password_current: user.password
            }
          }
        end

        it { is_expected.to respond_with(:no_content) }

        it 'destroys the user' do
          expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
