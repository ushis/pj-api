require 'rails_helper'

describe V1::PositionsController do
  describe 'GET #show' do
    before { set_auth_header(token) }

    let(:send_request) { get :show, car_id: id }

    let(:id) { car.id }

    let(:car) { create(:car) }

    context 'as anonymous user' do
      let(:token) { nil }

      before { send_request }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid car id' do
        let(:id) { 0 }

        before { send_request }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        before { create(:position, car: car) }

        before { send_request }

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        context 'with no position' do
          before { send_request }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'with position' do
          before { create(:position, car: car) }

          before { send_request }

          it { is_expected.to respond_with(:success) }

          it 'responds with the position' do
            expect(json[:position]).to eq(position_json(car.position))
          end
        end
      end
    end
  end

  [[:post, :create], [:patch, :update]].each do |method, action|
    describe "#{method} ##{action}" do
      before { create(:position, car: car) if method == :patch }

      before { set_auth_header(token) }

      before { send method, action, params.merge(car_id: id) }

      let(:id) { car.id }

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
          let(:id) { 0 }

          let(:params) { {} }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'who is not related to the car' do
          let(:params) { {} }

          it { is_expected.to respond_with(:forbidden) }
        end

        context 'who is related to the car' do
          let(:car) { user.cars.sample }

          context 'with missing params' do
            let(:params) { {} }

            it { is_expected.to respond_with(:unprocessable_entity) }
          end

          context 'with invalid latitude' do
            let(:params) do
              {
                position: {
                  latitude: [nil, -93.52, 111.11].sample,
                  longitude: build(:position).longitude
                }
              }
            end

            it { is_expected.to respond_with(:unprocessable_entity) }

            it 'responds with error details' do
              expect(json[:details][:latitude]).to be_present
            end
          end

          context 'with invalid longitude' do
            let(:params) do
              {
                position: {
                  latitude: build(:position).latitude,
                  longitude: [nil, -183.52, 211.11].sample
                }
              }
            end

            it { is_expected.to respond_with(:unprocessable_entity) }

            it 'responds with error details' do
              expect(json[:details][:longitude]).to be_present
            end
          end

          context 'with valid params' do
            let(:params) do
              {
                position: {
                  latitude: build(:position).latitude,
                  longitude: build(:position).longitude
                }
              }
            end

            it 'is a success' do
              expect(response).to be_success
            end

            it 'responds with the position' do
              expect(json[:position]).to eq(position_json(car.reload.position))
            end

            it 'set the correct latitude' do
              expect(car.reload.position.latitude).to eq(params[:position][:latitude])
            end

            it 'set the correct longitude' do
              expect(car.reload.position.longitude).to eq(params[:position][:longitude])
            end
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { set_auth_header(token) }

    let(:send_request) { delete :destroy, car_id: id }

    let(:id) { car.id }

    let(:car) { create(:car) }

    context 'as anonymous user' do
      before { send_request }

      let(:token) { nil }

      it { is_expected.to respond_with(:unauthorized) }
    end

    context 'as logged in user' do
      let(:token) { user.access_token }

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid car id' do
        let(:id) { 0 }

        before { send_request }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        before { create(:position, car: car) }

        before { send_request }

        it { is_expected.to respond_with(:forbidden) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        context 'with no position' do
          before { send_request }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'with position' do
          before { create(:position, car: car) }

          before { send_request }

          it { is_expected.to respond_with(:no_content) }

          it 'destroys the position' do
            expect {
              car.reload.position!
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
