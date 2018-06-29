require 'rails_helper'

describe V1::LocationsController do
  describe 'GET #show' do
    before { set_auth_header(token) }

    let(:send_request) { get :show, params: {car_id: id} }

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
        before { create(:location, car: car) }

        before { send_request }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        context 'with no location' do
          before { send_request }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'with location' do
          before { create(:location, car: car) }

          before { send_request }

          it { is_expected.to respond_with(:success) }

          it 'responds with the location' do
            expect(json[:location]).to eq(location_json(car.reload.location))
          end
        end
      end
    end
  end

  [[:post, :create], [:patch, :update]].each do |method, action|
    describe "#{method} ##{action}" do
      before { create(:location, car: car) if method == :patch }

      before { set_auth_header(token) }

      before { send method, action, params: params.merge(car_id: id) }

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

          it { is_expected.to respond_with(:not_found) }
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
                location: {
                  latitude: [nil, -93.52, 111.11].sample,
                  longitude: build(:location).longitude
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
                location: {
                  latitude: build(:location).latitude,
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
                location: {
                  latitude: build(:location).latitude,
                  longitude: build(:location).longitude
                }
              }
            end

            it 'is successful' do
              expect(response).to be_successful
            end

            it 'responds with the location' do
              expect(json[:location]).to eq(location_json(car.reload.location))
            end

            it 'sets the correct user' do
              expect(car.reload.location.user).to eq(user)
            end

            it 'sets the correct latitude' do
              expect(car.reload.location.latitude).to \
                be_within(1e-10).of(params[:location][:latitude])
            end

            it 'sets the correct longitude' do
              expect(car.reload.location.longitude).to \
                be_within(1e-10).of(params[:location][:longitude])
            end

            describe 'emails' do
              let(:car) do
                create(:car, owners: [user] + owners, borrowers: borrowers)
              end

              let(:owners) { create_list(:user, 2) }

              let(:borrowers) { create_list(:user, 2) }

              subject { ActionMailer::Base.deliveries }

              let(:from) do
                Mail::Address.new(ENV['MAIL_FROM']).tap do |address|
                  address.display_name = user.username
                end.to_s
              end

              its(:length) { is_expected.to eq(2) }

              it 'sends mails to the owners' do
                expect(subject.map(&:to).flatten).to \
                  match_array(owners.map(&:email))
              end

              it 'sends a location update email' do
                expect(subject.first.subject).to include('location')
              end

              it 'has the correct car name' do
                expect(subject.first.subject).to include(car.name)
              end

              it 'sets the correct From header' do
                expect(subject.first.header['From'].to_s).to eq(from)
              end
            end
          end
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before { set_auth_header(token) }

    let(:send_request) { delete :destroy, params: {car_id: id} }

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
        before { create(:location, car: car) }

        before { send_request }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is related to the car' do
        let(:car) { user.cars.sample }

        context 'with no location' do
          before { send_request }

          it { is_expected.to respond_with(:not_found) }
        end

        context 'with location' do
          before { create(:location, car: car) }

          before { send_request }

          it { is_expected.to respond_with(:no_content) }

          it 'destroys the location' do
            expect {
              car.reload.location!
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
