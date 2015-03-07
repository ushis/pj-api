require 'rails_helper'

describe V1::BorrowershipsController do
  describe 'GET #index' do
    let!(:borrowerships) { create_list(:borrowership, 2, car: car) }

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

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        let(:all) { borrowerships + user.borrowerships.where(car_id: car) }

        it { is_expected.to respond_with(:success) }

        it 'responds with the cars borrowerships' do
          expect(json[:borrowerships]).to match_array(borrowerships_json(all))
        end
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with the cars borrowerships' do
          expect(json[:borrowerships]).to \
            match_array(borrowerships_json(borrowerships))
        end
      end
    end
  end


  describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show, car_id: car_id, id: id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:id) { borrowership.id }

    let(:borrowership) { create(:borrowership, car: car) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'with invalid id' do
        let(:id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with the borrowership' do
          expect(json[:borrowership]).to eq(borrowership_json(borrowership))
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

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        let(:params) { {} }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        let(:params) { {} }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        let(:params) do
          {
            borrowership: {
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
              borrowership: {
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
              borrowership: {
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
              borrowership: {
                user_id: other.id
              }
            }
          end

          let(:other) { create(:user) }

          let(:borrowership) { Borrowership.find(json[:borrowership][:id]) }

          it { is_expected.to respond_with(:created) }

          it 'responds with the borrowership' do
            expect(json[:borrowership]).to eq(borrowership_json(borrowership))
          end

          it 'sets the correct car' do
            expect(borrowership.car).to eq(car)
          end

          it 'sets the correct user' do
            expect(borrowership.user).to eq(other)
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

    let(:id) { borrowership.id }

    let(:borrowership) { create(:borrowership, car: car) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'with invalid id' do
        let(:id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        it { is_expected.to respond_with(:forbidden) }

        context 'and removes his borrowership' do
          let(:borrowership) { user.borrowerships.find_by!(car_id: car) }

          it { is_expected.to respond_with(:no_content) }

          it 'destroys the borrowership' do
            expect { borrowership.reload }.to \
              raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:no_content) }

        it 'destroys the borrowership' do
          expect { borrowership.reload }.to \
            raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
