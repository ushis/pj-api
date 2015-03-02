require 'rails_helper'

describe V1::OwnershipsController do
  describe 'GET #index' do
    let!(:ownerships) { create_list(:ownership, 2, car: car) }

    before { set_auth_header(token) }

    before { get :index, car_id: car_id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:success) }

        it 'responds with nothing' do
          expect(json[:ownerships]).to be_empty
        end
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with the cars ownerships' do
          expect(json[:ownerships]).to match_array(ownerships_json(ownerships))
        end
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        let(:all) { ownerships + user.ownerships.where(car_id: car) }

        it { is_expected.to respond_with(:success) }

        it 'responds with the cars ownerships' do
          expect(json[:ownerships]).to match_array(ownerships_json(all))
        end
      end
    end
  end

  describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show, car_id: car_id, id: id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:id) { ownership.id }

    let(:ownership) { create(:ownership, car: car) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'with invalid id' do
        let(:id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with the ownership' do
          expect(json[:ownership]).to eq(ownership_json(ownership))
        end
      end
    end
  end

  describe 'POST #create' do
    before { set_auth_header(token) }

    before { post :create, params.merge(car_id: car_id) }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    context 'as anonymous user' do
      let(:token) { nil }

      let(:params) { {} }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        let(:params) { {} }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        let(:params) do
          {
            ownership: {
              user_id: 0
            }
          }
        end

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        let(:params) do
          {
            ownership: {
              user_id: 0
            }
          }
        end

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        context 'with invalid user id' do
          let(:params) do
            {
              ownership: {
                user_id: 0
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:user]).to be_present
          end
        end

        context 'with duplicate user id' do
          let(:params) do
            {
              ownership: {
                user_id: borrowership.user.id
              }
            }
          end

          let(:borrowership) { create(:borrowership, car: car) }

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:user_id]).to be_present
          end
        end

        context 'with valid params' do
          let(:params) do
            {
              ownership: {
                user_id: other.id
              }
            }
          end

          let(:other) { create(:user) }

          let(:ownership) { Ownership.find(json[:ownership][:id]) }

          it { is_expected.to respond_with(:created) }

          it 'responds with the ownership' do
            expect(json[:ownership]).to eq(ownership_json(ownership))
          end

          it 'sets the correct car' do
            expect(ownership.car).to eq(car)
          end

          it 'sets the correct user' do
            expect(ownership.user).to eq(other)
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { set_auth_header(token) }

    before { delete :destroy, car_id: car_id, id: id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:id) { ownership.id }

    let(:ownership) { create(:ownership, car: car) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_cars, :with_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

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

        context 'and is the only owner' do
          let(:ownership) { user.ownerships.find_by!(car_id: car) }

          it { is_expected.to respond_with(:forbidden) }
        end

        context 'and removes another owner' do
          it { is_expected.to respond_with(:no_content) }

          it 'destroys the ownership' do
            expect { ownership.reload }.to \
              raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
