class V1::PositionsController < V1::ApplicationController
  before_action :find_car
  before_action :find_position!, only: [:show, :destroy]
  before_action :find_position,  only: [:create, :update]

  # GET /v1/cars/:car_id/position
  def show
    render json: @position
  end

  # POST /v1/cars/:car_id/position
  def create
    if @position.update(position_params)
      render json: @position, status: :created
    else
      render_error :unprocessable_entity, @position.errors
    end
  end

  # PATCH /v1/cars/:car_id/position
  def update
    if @position.update(position_params)
      render json: @position
    else
      render_error :unprocessable_entity, @position.errors
    end
  end

  # DELETE /v1/cars/:car_id/position
  def destroy
    if @position.destroy
      head :no_content
    else
      render_error :unprocessable_entity, @position.errors
    end
  end

  private

  # Finds the requested car
  def find_car
    @car = Car.find(params[:car_id])
  end

  # Finds the requested position
  def find_position!
    @position = @car.position!
    authorize @position
  end

  # Finds the requested position or builds a new one
  def find_position
    @position = @car.position || @car.build_position
    authorize @position
  end

  # Returns the permitted position parameters
  def position_params
    params
      .require(:position)
      .permit(*policy(@position).permitted_attributes)
  end
end
