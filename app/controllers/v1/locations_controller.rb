class V1::LocationsController < V1::ApplicationController
  before_action :find_car
  before_action :find_location!, only: [:show, :destroy]
  before_action :find_location,  only: [:create, :update]

  # GET /v1/cars/:car_id/location
  def show
    render json: @location, serializer: LocationSerializer
  end

  # POST /v1/cars/:car_id/location
  def create
    if @location.update(location_params.merge(user: current_user))
      LocationUpdatedMailJob.perform_later(@location)
      render json: @location, serializer: LocationSerializer, status: :created
    else
      render_error :unprocessable_entity, @location.errors
    end
  end

  # PATCH /v1/cars/:car_id/location
  def update
    if @location.update(location_params.merge(user: current_user))
      LocationUpdatedMailJob.perform_later(@location)
      render json: @location, serializer: LocationSerializer
    else
      render_error :unprocessable_entity, @location.errors
    end
  end

  # DELETE /v1/cars/:car_id/location
  def destroy
    @location.destroy!
    head :no_content
  end

  private

  # Finds the requested car
  def find_car
    @car = current_user.cars.find(params[:car_id])
  end

  # Finds the requested location
  def find_location!
    @location = @car.location!
    authorize @location
  end

  # Finds the requested location or builds a new one
  def find_location
    @location = @car.location || @car.build_location
    authorize @location
  end

  # Returns the permitted location parameters
  def location_params
    params
      .require(:location)
      .permit(*policy(@location).permitted_attributes)
  end
end
