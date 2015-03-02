class V1::OwnershipsController < V1::ApplicationController
  before_action :find_car
  before_action :find_ownership, only: [:show, :destroy]

  # GET /v1/cars/:car_id/ownerships
  def index
    @ownerships = policy_scope(@car.ownerships)
      .search(params[:q])
      .order('users.username')
      .page(params[:page])
      .per(params[:per_page])

    render json: @ownerships, meta: index_meta_data
  end

  # GET /v1/cars/:car_id/ownerships/:id
  def show
    render json: @ownership
  end

  # POST /v1/cars/:car_id/ownerships
  def create
    @ownership = @car.ownerships.build(ownership_params)
    authorize @ownership

    if @ownership.save
      render json: @ownership, status: :created
    else
      render_error :unprocessable_entity, @ownership.errors
    end
  end

  # DELETE /v1/cars/:car_id/ownerships/:id
  def destroy
    if @ownership.destroy
      head :no_content
    else
      render_error :unprocessable_entity, @ownership.errors
    end
  end

  private

  # Finds thew requested car
  def find_car
    @car = Car.find(params[:car_id])
  end

  # Finds the requested ownership
  def find_ownership
    @ownership = @car.ownerships.find(params[:id])
    authorize @ownership
  end

  # Returns the permitted ownership attributes
  def ownership_params
    params
      .require(:ownership)
      .permit(*policy(@ownership || Ownership.new).permitted_attributes)
  end

  # Returns the meta data for the index request
  def index_meta_data
    {
      q: params[:q],
      page: @ownerships.current_page,
      per_page: @ownerships.limit_value,
      total_pages: @ownerships.total_pages
    }
  end
end
