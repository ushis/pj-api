require 'rails_helper'

describe V1::RidesController do
  describe 'GET #index' do
    let!(:rides) { create_list(:ride, 2, car: car) }

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

        it 'responds with no rides' do
          expect(json[:rides]).to be_empty
        end
      end

      context 'who is releated to the car' do
        let(:car) { user.cars.sample }

        it { is_expected.to respond_with(:success) }

        it 'responds with cars rides' do
          expect(json[:rides]).to match_array(rides_json(rides))
        end
      end
    end
  end

  describe 'GET #show' do
    before { set_auth_header(token) }

    before { get :show, car_id: car_id, id: id }

    let(:car_id) { car.id }

    let(:car) { create(:car) }

    let(:id) { ride.id }

    let(:ride) { create(:ride, car: car) }

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

        it 'responds with the ride' do
          expect(json[:ride]).to eq(ride_json(ride))
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
            ride: {
              distance: build(:ride).distance
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

        context 'with invalid distance' do
          let(:params) do
            {
              ride: {
                distance: [-121, 0, 'invalid', nil].sample,
                started_at: 3.days.ago,
                ended_at: 1.day.ago
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:distance]).to be_present
          end
        end

        context 'with invalid started_at' do
          let(:params) do
            {
              ride: {
                distance: build(:ride).distance,
                started_at: nil,
                ended_at: 1.day.ago
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:started_at]).to be_present
          end
        end

        context 'with invalid ended_at' do
          let(:params) do
            {
              ride: {
                distance: build(:ride).distance,
                started_at: 3.days.ago,
                ended_at: [4.days.ago, nil].sample
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:ended_at]).to be_present
          end
        end

        context 'with valid params' do
          let(:params) do
            {
              ride: {
                distance: build(:ride).distance,
                started_at: 3.days.ago,
                ended_at: 1.day.ago
              }
            }
          end

          let(:ride) { Ride.find(json[:ride][:id]) }

          it { is_expected.to respond_with(:created) }

          it 'responds with the ride' do
            expect(json[:ride]).to eq(ride_json(ride))
          end

          it 'sets the correct distance' do
            expect(ride.distance).to eq(params[:ride][:distance])
          end

          it 'sets the correct started_at' do
            expect(ride.started_at).to be_within(1).of(params[:ride][:started_at])
          end

          it 'sets the correct ended_at' do
            expect(ride.ended_at).to be_within(1).of(params[:ride][:ended_at])
          end

          it 'sets the correct user' do
            expect(ride.user).to eq(user)
          end

          it 'sets the correct car' do
            expect(ride.car).to eq(car)
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

    let(:id) { ride.id }

    let(:ride) { create(:ride, car: car) }

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

        context 'and did the ride' do
          let(:ride) { create(:ride, car: car, user: user) }

          let(:params) do
            {
              ride: {
                distance: build(:ride).distance
              }
            }
          end

          it { is_expected.to respond_with(:success) }

          it 'responds with the ride' do
            expect(json[:ride]).to eq(ride_json(ride.reload))
          end
        end
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        context 'with invalid distance' do
          let(:params) do
            {
              ride: {
                distance: [-121, 0].sample
              }
            }
          end

          it { is_expected.to respond_with(:unprocessable_entity) }

          it 'responds with error details' do
            expect(json[:details][:distance]).to be_present
          end
        end

        context 'with valid params' do
          let(:params) do
            {
              ride: {
                distance: build(:ride).distance,
                started_at: 4.days.ago,
                ended_at: 3.day.ago
              }
            }
          end

          it { is_expected.to respond_with(:success) }

          it 'responds with the ride' do
            expect(json[:ride]).to eq(ride_json(ride.reload))
          end

          it 'sets the correct distance' do
            expect(ride.reload.distance).to eq(params[:ride][:distance])
          end

          it 'sets the correct started_at' do
            expect(ride.reload.started_at).to be_within(1).of(params[:ride][:started_at])
          end

          it 'sets the correct ended_at' do
            expect(ride.reload.ended_at).to be_within(1).of(params[:ride][:ended_at])
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

    let(:id) { ride.id }

    let(:ride) { create(:ride, car: car) }

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

        context 'and did the ride' do
          let(:ride) { create(:ride, car: car, user: user) }

          it { is_expected.to respond_with(:no_content) }

          it 'destroys the ride' do
            expect { ride.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'who owns the car' do
        let(:car) { user.owned_cars.sample }

        it { is_expected.to respond_with(:no_content) }

        it 'destroys the ride' do
          expect { ride.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
