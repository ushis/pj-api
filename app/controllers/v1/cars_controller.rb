class V1::CarsController < V1::ApplicationController
  before_action :find_car, only: [:show, :update, :destroy]

  # GET /v1/cars
  def index
    @cars = policy_scope(current_user.cars)
      .search(params[:q])
      .order(:name)
      .page(params[:page])
      .per(params[:per_page])

    render json: @cars, meta: index_meta_data
  end

  # GET /v1/cars/:id
  def show
    render json: @car
  end

  # POST /v1/cars
  def create
    @car = current_user.owned_cars.build(car_params)
    authorize @car

    if @car.save
      render json: @car, status: :created
    else
      render_error :unprocessable_entity, @car.errors
    end
  end

  # PATCH /v1/cars/:id
  def update
    if @car.update(car_params)
      render json: @car
    else
      render_error :unprocessable_entity, @car.errors
    end
  end

  # DELETE /v1/cars/:id
  def destroy
    if @car.destroy
      head :no_content
    else
      render_error :unprocessable_entity, @car.errors
    end
  end

  private

  # Finds the requested car
  def find_car
    @car = Car.find(params[:id])
    authorize(@car)
  end

  # Returns the permitted car parameters
  def car_params
    params
      .require(:car)
      .permit(*policy(@car || Car.new).permitted_attributes)
  end

  # Returns the meta data for the index request
  def index_meta_data
    {
      q: params[:q],
      page: @cars.current_page,
      per_page: @cars.limit_value,
      total_pages: @cars.total_pages
    }
  end
end
