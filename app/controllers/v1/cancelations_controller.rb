class V1::CancelationsController < V1::ApplicationController
  before_action :find_car
  before_action :find_reservation
  before_action :find_cancelation, only: [:create]
  before_action :find_cancelation!, only: [:show, :destroy]

  # GET /v1/cars/:car_id/reservations/:reservation_id/cancelation
  def show
    render json: @cancelation, serializer: CancelationSerializer
  end

  # POST /v1/cars/:car_id/reservations/:reservation_id/cancelation
  def create
    @cancelation.update!(user: current_user)
    render json: @cancelation, serializer: CancelationSerializer, status: :created
  end

  # DELETE /v1/cars/:car_id/reservations/:reservation_id/cancelation
  def destroy
    @cancelation.destroy!
    head :no_content
  end

  private

  def find_car
    @car = current_user.cars.find(params[:car_id])
  end

  def find_reservation
    @reservation = @car.reservations.find(params[:reservation_id])
  end

  def find_cancelation
    @cancelation = @reservation.cancelation || @reservation.build_cancelation
    authorize @cancelation
  end

  def find_cancelation!
    @cancelation = @reservation.cancelation!
    authorize @cancelation
  end
end
