require 'rails_helper'

describe V1::CarsController do
  describe 'GET #index' do
    before { create_list(:car, 2) }

    before { set_auth_header(token) }

    before { get :index }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      it { is_expected.to respond_with(:success) }

      it 'responds with the users cars' do
        expect(json[:cars]).to match_array(cars_json(user.cars))
      end
    end
  end

  describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show, id: id }

    let(:id) { car.id }

    let(:car) { create(:car) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      context 'with invalid id' do
        let(:id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with the car' do
          expect(json[:car]).to eq(car_json(car))
        end
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with the car' do
          expect(json[:car]).to eq(car_json(car))
        end
      end
    end
  end

  describe 'POST #create' do
    before { set_auth_header(token) }

    before { post :create, params }

    context 'as anonymous user' do
      let(:token) { nil }

      let(:params) { {} }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user) }

      context 'with missing params' do
        let(:params) { {} }

        it { is_expected.to respond_with(:unprocessable_entity) }
      end

      context 'with invalid name' do
        let(:params) do
          {
            car: {
              name: nil
            }
          }
        end

        it { is_expected.to respond_with(:unprocessable_entity) }

        it 'responds with error details' do
          expect(json[:details][:name]).to be_present
        end
      end

      context 'with valid name' do
        let(:params) do
          {
            car: {
              name: 'my fancy car'
            }
          }
        end

        let(:car) { Car.find(json[:car][:id]) }

        it { is_expected.to respond_with(:created) }

        it 'responds with the car' do
          expect(json[:car]).to eq(car_json(car))
        end

        it 'sets the correct name' do
          expect(car.name).to eq(params[:car][:name])
        end

        it 'registers the user as owner' do
          expect(user.owns?(car)).to be true
        end
      end
    end
  end

  describe 'PATCH #update' do
    before { set_auth_header(token) }

    before { patch :update, params.merge(id: id) }

    let(:id) { car.id }

    let(:car) { create(:car) }

    context 'as anonymous user' do
      let(:token) { nil }

      let(:params) { {} }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      context 'with invalid id' do
        let(:id) { 0 }

        let(:params) { {} }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        let(:params) { {} }

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        let(:params) { {} }

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        context 'without params' do
          let(:params) { {} }

          it { is_expected.to respond_with(:unprocessable_entity) }
        end

        context 'with invalid name' do
          let(:params) do
            {
              car: {
                name: nil
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:name]).to be_present
          end
        end

        context 'with valid name' do
          let(:params) do
            {
              car: {
                name: 'my fancy car'
              }
            }
          end

          it { is_expected.to respond_with(:success) }

          it 'responds with the car' do
            expect(json[:car]).to eq(car_json(car.reload))
          end

          it 'sets the new name' do
            expect(car.reload.name).to eq(params[:car][:name])
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { set_auth_header(token) }

    before { delete :destroy, id: id }

    let(:id) { car.id }

    let(:car) { create(:car) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      context 'with invalid id' do
        let(:id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:no_content) }

        it 'destroys the car' do
          expect { car.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
