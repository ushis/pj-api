class V1::RidesController < V1::ApplicationController
  before_action :find_car
  before_action :find_ride, only: [:show, :update, :destroy]

  # GET /v1/cars/:car_id/rides
  def index
    @rides = @car.rides
      .includes(:user)
      .after(datetime_param(:after))
      .before(datetime_param(:before))
      .order_by(params[:order_by], params[:order])
      .page(params[:page])
      .per(params[:per_page])

    render json: @rides, meta: index_meta_data
  end

  # GET /v1/cars/:car_id/rides/:id
  def show
    render json: @ride
  end

  # POST /v1/cars/:car_id/rides
  def create
    @ride = @car.rides.build(ride_params_with_user)
    authorize @ride

    if @ride.save
      render json: @ride, status: :created
    else
      render_error :unprocessable_entity, @ride.errors
    end
  end

  # PATCH /v1/cars/:car_id/rides/:id
  def update
    if @ride.update(ride_params)
      render json: @ride
    else
      render_error :unprocessable_entity, @ride.errors
    end
  end

  # DELETE /v1/cars/:car_id/rides/:id
  def destroy
    if @ride.destroy
      head :no_content
    else
      render_error :unprocessable_entity, @ride.errors
    end
  end

  private

  # Finds the requested car
  def find_car
    @car = current_user.cars.find(params[:car_id])
  end

  # Finds the requested ride
  def find_ride
    @ride = @car.rides.find(params[:id])
    authorize @ride
  end

  # Returns the permitted ride parameters
  def ride_params
    params
      .require(:ride)
      .permit(*policy(@ride || Ride.new).permitted_attributes)
  end

  # Returns the permitted ride parameters including the current user
  def ride_params_with_user
    ride_params.merge(user: current_user)
  end

  # Returns the meta data for the index request
  def index_meta_data
    {
      after: datetime_param(:after),
      before: datetime_param(:before),
      order: params[:order],
      order_by: params[:order_by],
      page: @rides.current_page,
      per_page: @rides.limit_value,
      total_pages: @rides.total_pages
    }
  end
end
