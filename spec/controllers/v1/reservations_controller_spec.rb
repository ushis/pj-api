require 'rails_helper'

describe V1::ReservationsController do
  describe 'GET #index' do
    let!(:reservations) { create_list(:reservation, 2, car: car) }

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

        it 'responds with no reservations' do
          expect(json[:reservations]).to be_empty
        end
      end

      context 'who is releated to the car' do
        let(:car) { user.cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with cars reservations' do
          expect(json[:reservations]).to \
            match_array(reservations_json(reservations))
        end
      end
    end
  end

 describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show, car_id: car_id, id: id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:id) { reservation.id }

    let(:reservation) { create(:reservation, car: car) }

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

        it 'responds with the reservation' do
          expect(json[:reservation]).to eq(reservation_json(reservation))
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
            reservation: {
              starts_at: 3.days.from_now,
              ends_at: 5.days.from_now
            }
          }
        end

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        context 'with missing params' do
          let(:params) { {} }

          it { is_expected.to respond_with(:unprocessable_entity) }
        end

        context 'with invalid starts_at' do
          let(:params) do
            {
              reservation: {
                starts_at: nil,
                ends_at: 1.day.from_now
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:starts_at]).to be_present
          end
        end

        context 'with invalid ends_at' do
          let(:params) do
            {
              reservation: {
                starts_at: 3.days.from_now,
                ends_at: [2.days.from_now, nil].sample
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:ends_at]).to be_present
          end
        end

        context 'with valid params' do
          let(:params) do
            {
              reservation: {
                starts_at: 3.days.from_now,
                ends_at: 5.days.from_now
              }
            }
          end

          let(:reservation) { Reservation.find(json[:reservation][:id]) }

          it { is_expected.to respond_with(:created) }

          it 'responds with the reservation' do
            expect(json[:reservation]).to eq(reservation_json(reservation))
          end

          it 'sets the correct starts_at' do
            expect(reservation.starts_at).to \
              be_within(1).of(params[:reservation][:starts_at])
          end

          it 'sets the correct ends_at' do
            expect(reservation.ends_at).to \
              be_within(1).of(params[:reservation][:ends_at])
          end

          it 'sets the correct user' do
            expect(reservation.user).to eq(user)
          end

          it 'sets the correct car' do
            expect(reservation.car).to eq(car)
          end
        end
      end
    end
  end

  describe 'PATCH #update' do
    before { set_auth_header(token) }

    before { patch :update, params.merge(car_id: car_id, id: id) }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:id) { reservation.id }

    let(:reservation) { create(:reservation, car: car) }

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

        context 'and did the reservation' do
          let(:reservation) { create(:reservation, car: car, user: user) }

          let(:params) do
            {
              reservation: {
                starts_at: 1.day.from_now
              }
            }
          end

          it { is_expected.to respond_with(:success) }

          it 'responds with the reservation' do
            expect(json[:reservation]).to \
              eq(reservation_json(reservation.reload))
          end
        end
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        context 'with invalid ends_at' do
          let(:params) do
            {
              reservation: {
                starts_at: 4.days.from_now,
                ends_at: 1.day.from_now
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:ends_at]).to be_present
          end
        end

        context 'with valid params' do
          let(:params) do
            {
              reservation: {
                starts_at: 4.days.from_now,
                ends_at: 5.days.from_now
              }
            }
          end

          it { is_expected.to respond_with(:success) }

          it 'responds with the reservation' do
            expect(json[:reservation]).to \
              eq(reservation_json(reservation.reload))
          end

          it 'sets the correct starts_at' do
            expect(reservation.reload.starts_at).to \
              be_within(1).of(params[:reservation][:starts_at])
          end

          it 'sets the correct ends_at' do
            expect(reservation.reload.ends_at).to \
              be_within(1).of(params[:reservation][:ends_at])
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

    let(:id) { reservation.id }

    let(:reservation) { create(:reservation, car: car) }

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

        context 'and did the reservation' do
          let(:reservation) { create(:reservation, car: car, user: user) }

          it { is_expected.to respond_with(:no_content) }

          it 'destroys the reservation' do
            expect { reservation.reload }.to \
              raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:no_content) }

        it 'destroys the reservation' do
          expect { reservation.reload }.to \
            raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
