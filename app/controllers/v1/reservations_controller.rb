class V1::ReservationsController < V1::ApplicationController
  before_action :find_car
  before_action :find_reservation, only: [:show, :update, :destroy]

  # GET /v1/cars/:car_id/reservations
  def index
    @reservations = @car.reservations
      .includes(:user)
      .after(datetime_param(:after))
      .before(datetime_param(:before))
      .order(params[:order_by], params[:order])
      .page(params[:page])
      .per(params[:per_page])

    render json: @reservations, meta: index_meta_data
  end

  # PATCH /v1/cars/:car_id/reservations/:id
  def show
    render json: @reservation
  end

  # PATCH /v1/cars/:car_id/reservations/:id
  def create
    @reservation = @car.reservations.build(reservation_params_with_user)
    authorize @reservation

    if @reservation.save
      ReservationCreatedMailJob.perform_later(@reservation)
      render json: @reservation, status: :created
    else
      render_error :unprocessable_entity, @reservation.errors
    end
  end

  # PATCH /v1/cars/:car_id/reservations/:id
  def update
    if @reservation.update(reservation_params)
      render json: @reservation
    else
      render_error :unprocessable_entity, @reservation.errors
    end
  end

  # DELETE /v1/cars/:car_id/reservations/:id
  def destroy
    if @reservation.destroy
      head :no_content
    else
      render_error :unprocessable_entity, @reservation.errors
    end
  end

  private

  # Finds the requested car
  def find_car
    @car = current_user.cars.find(params[:car_id])
  end

  # Finds the requested reservation
  def find_reservation
    @reservation = @car.reservations.find(params[:id])
    authorize @reservation
  end

  # Returns the permitted reservation parameters
  def reservation_params
    params
      .require(:reservation)
      .permit(*policy(@reservation || Reservation.new).permitted_attributes)
  end

  # Returns the permitted reservation parameters including the current user
  def reservation_params_with_user
    reservation_params.merge(user: current_user)
  end

  # Returns the meta data for the index request
  def index_meta_data
    {
      after: datetime_param(:after),
      before: datetime_param(:before),
      order: params[:order],
      order_by: params[:order_by],
      page: @reservations.current_page,
      per_page: @reservations.limit_value,
      total_pages: @reservations.total_pages
    }
  end
end
