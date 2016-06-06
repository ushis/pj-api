require 'rails_helper'

describe V1::CancelationsController do
  describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show, car_id: car_id, reservation_id: reservation_id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:reservation_id) { reservation.id }

    let(:reservation) do
      create(:reservation, car: car, cancelation: cancelation)
    end

    let(:cancelation) { create(:cancelation) }

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

      context 'with invalid reservation_id' do
        let(:reservation_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with the cancelation' do
          expect(json[:cancelation]).to eq(cancelation_json(cancelation))
        end

        context 'without a cancelation' do
          let(:cancelation) { nil }

          it { is_expected.to respond_with(:not_found) }
        end
      end
    end
  end

  describe 'POST #create' do
    before { set_auth_header(token) }

    before { post :create, car_id: car_id, reservation_id: reservation_id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:reservation_id) { reservation.id }

    let(:reservation) { create(:reservation, car: car) }

    let(:cancelation) { reservation.cancelation(true) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid reservation_id' do
        let(:reservation_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        it { is_expected.to respond_with(:forbidden) }

        context 'and made the reservation' do
          let(:reservation) { create(:reservation, car: car, user: user) }

          it { is_expected.to respond_with(:created) }

          it 'responds with the cancelation' do
            expect(json[:cancelation]).to eq(cancelation_json(cancelation))
          end

          it 'sets the correct user' do
            expect(cancelation.user).to eq(user)
          end
        end
      end

      context 'who owns the reservation' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:created) }

        it 'responds with the cancelation' do
          expect(json[:cancelation]).to eq(cancelation_json(cancelation))
        end

        it 'sets the correct user' do
          expect(cancelation.user).to eq(user)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { set_auth_header(token) }

    before { delete :destroy, car_id: car_id, reservation_id: reservation_id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:reservation_id) { reservation.id }

    let(:reservation) do
      create(:reservation, car: car, cancelation: cancelation)
    end

    let(:cancelation) { create(:cancelation) }

    context 'as anonymous user' do
      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid reservation_id' do
        let(:reservation_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
      end

      context 'who borrows the car' do
        let(:car) { user.borrowed_cars.sample }

        it { is_expected.to respond_with(:forbidden) }

        context 'and made the reservation' do
          let(:reservation) do
            create(:reservation, car: car, user: user, cancelation: cancelation)
          end

          it { is_expected.to respond_with(:no_content) }

          it 'destroys the cancelation' do
            expect {
              cancelation.reload
            }.to raise_error(ActiveRecord::RecordNotFound)
          end

          context 'without an cancelation' do
            let(:cancelation) { nil }

            it { is_expected.to respond_with(:not_found) }
          end
        end
      end

      context 'who owns the reservation' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:no_content) }

        it 'destroys the cancelation' do
          expect {
            cancelation.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context 'without an cancelation' do
          let(:cancelation) { nil }

          it { is_expected.to respond_with(:not_found) }
        end
      end
    end
  end
end
