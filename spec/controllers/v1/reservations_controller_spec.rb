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

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

      context 'with invalid car id' do
        let(:car_id) { 0 }

        it { is_expected.to respond_with(:not_found) }
      end

      context 'who is not related to the car' do
        it { is_expected.to respond_with(:not_found) }
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

          describe 'emails' do
            let(:car) do
              create(:car, owners: [user] + owners, borrowers: borrowers)
            end

            let(:owners) { create_list(:user, 2) }

            let(:borrowers) { create_list(:user, 2) }

            subject { ActionMailer::Base.deliveries }

            let(:sample) { subject.sample }

            let(:sample_reply_to) { sample.reply_to.first }

            let(:sample_reply_address) { ReplyAddress.decode(sample_reply_to) }

            let(:sample_message_id) { sample.message_id }

            let(:sample_from) { sample.header['From'].to_s }

            let(:expected_from) do
              Mail::Address.new(ENV['MAIL_FROM']).tap do |address|
                address.display_name = user.username
              end.to_s
            end

            let(:sample_recipient) do
              owners.find { |u| u.email == sample.to.first }
            end

            its(:length) { is_expected.to eq(2) }

            it 'sends mails to the owners' do
              expect(subject.map(&:to).flatten).to \
                match_array(owners.map(&:email))
            end

            it 'sends a reservation created email' do
              expect(subject.first.subject).to include("I need #{car.name} between")
            end

            it 'sets the correct user in the Reply-To header' do
              expect(sample_reply_address.user).to eq(sample_recipient)
            end

            it 'sets the correct records in the Reply-To header' do
              expect(sample_reply_address.record).to eq(reservation)
            end

            it 'sets the correct Message-Id header' do
              expect(sample_message_id).to eq(MessageID.new(car, reservation).id)
            end

            it 'sets the correct From header' do
              expect(sample_from).to eq(expected_from)
            end
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

      let(:user) { create(:user, :with_owned_and_borrowed_cars) }

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

        it { is_expected.to respond_with(:not_found) }
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
