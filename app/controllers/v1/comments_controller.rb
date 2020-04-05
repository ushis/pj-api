class V1::CommentsController < V1::ApplicationController
  before_action :find_car
  before_action :find_parent
  before_action :find_comment, only: [:show, :update, :destroy]

  # GET /v1/cars/:car_id/comments
  # GET /v1/cars/:car_id/rides/:ride_id/comments
  # GET /v1/cars/:car_id/reservations/:reservation_id/comments
  def index
    @comments = @parent.comments
      .includes(:user)
      .order_by(params[:order_by], params[:order])
      .page(params[:page])
      .per(params[:per_page])

    render json: @comments, each_serializer: CommentSerializer, meta: index_meta_data
  end

  # GET /v1/cars/:car_id/comments/:id
  # GET /v1/cars/:car_id/rides/:ride_id/comments/:id
  # GET /v1/cars/:car_id/reservations/:reservation_id/comments/:id
  def show
    render json: @comment, serializer: CommentSerializer
  end

  # POST /v1/cars/:car_id/comments
  # POST /v1/cars/:car_id/rides/:ride_id/comments
  # POST /v1/cars/:car_id/reservations/:reservation_id/comments
  def create
    @comment = @parent.comments.build(comment_params_with_user)
    authorize @comment

    if @comment.save
      CommentCreatedMailJob.perform_later(@comment)
      render json: @comment, serializer: CommentSerializer, status: :created
    else
      render_error :unprocessable_entity, @comment.errors
    end
  end

  # PATCH /v1/cars/:car_id/comments/:id
  # PATCH /v1/cars/:car_id/rides/:ride_id/comments/:id
  # PATCH /v1/cars/:car_id/reservations/:reservation_id/comments/:id
  def update
    if @comment.update(comment_params)
      render json: @comment, serializer: CommentSerializer
    else
      render_error :unprocessable_entity, @comment.errors
    end
  end

  # DELETE /v1/cars/:car_id/comments/:id
  # DELETE /v1/cars/:car_id/rides/:ride_id/comments/:id
  # DELETE /v1/cars/:car_id/reservations/:reservation_id/comments/:id
  def destroy
    @comment.destroy!
    head :no_content
  end

  private

  # Finds the requested car
  def find_car
    @car = current_user.cars.find(params[:car_id])
  end

  # Finds the requested parent record
  def find_parent
    if params.key?(:reservation_id)
      @parent = @car.reservations.find(params[:reservation_id])
    elsif params.key?(:ride_id)
      @parent = @car.rides.find(params[:ride_id])
    else
      @parent = @car
    end
  end

  # Finds the requested comment
  def find_comment
    @comment = @parent.comments.find(params[:id])
    authorize @comment
  end

  # Returns the permitted comment parameters
  def comment_params
    params
      .require(:comment)
      .permit(*policy(@comment || Comment.new).permitted_attributes)
  end

  # Returns the permitted comment parameters including the current user
  def comment_params_with_user
    comment_params.merge(user: current_user)
  end

  # Returns the meta data for the index request
  def index_meta_data
    {
      order: params[:order],
      order_by: params[:order_by],
      page: @comments.current_page,
      per_page: @comments.limit_value,
      total_pages: @comments.total_pages
    }
  end
end
