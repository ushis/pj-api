class V1::BorrowershipsController < V1::ApplicationController
  before_action :find_car
  before_action :find_borrowership, only: [:show, :destroy]

  # GET /v1/cars/:car_id/borrowerships
  def index
    @borrowerships = @car.borrowerships
      .includes(:user)
      .search(params[:q])
      .order_by(params[:order_by], params[:order])
      .page(params[:page])
      .per(params[:per_page])

    render json: @borrowerships, meta: index_meta_data
  end

  # GET /v1/cars/:car_id/borrowerships/:id
  def show
    render json: @borrowership
  end

  # POST /v1/cars/:car_id/borrowerships
  def create
    @borrowership = @car.borrowerships.build(borrowership_params)
    authorize @borrowership

    if @borrowership.save
      BorrowershipCreatedMailJob.perform_later(@borrowership, current_user)
      render json: @borrowership, status: :created
    else
      render_error :unprocessable_entity, @borrowership.errors
    end
  end

  # DELETE /v1/cars/:car_id/borrowerships/:id
  def destroy
    @borrowership.destroy!
    head :no_content
  end

  private

  # Finds thew requested car
  def find_car
    @car = current_user.cars.find(params[:car_id])
  end

  # Finds the requested borrowership
  def find_borrowership
    @borrowership = @car.borrowerships.find(params[:id])
    authorize @borrowership
  end

  # Returns the permitted borrowership attributes
  def borrowership_params
    params
      .require(:borrowership)
      .permit(*policy(@borrowership || Borrowership.new).permitted_attributes)
  end

  # Returns the meta data for the index request
  def index_meta_data
    {
      q: params[:q],
      order: params[:order],
      order_by: params[:order_by],
      page: @borrowerships.current_page,
      per_page: @borrowerships.limit_value,
      total_pages: @borrowerships.total_pages
    }
  end
end
