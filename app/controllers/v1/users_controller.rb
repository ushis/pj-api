class V1::UsersController < V1::ApplicationController
  before_action :find_user, only: [:show]

  # GET /v1/users
  def index
    @users = User
      .search(params[:q])
      .order(:username)
      .page(params[:page])
      .per(params[:per_page])

    render json: @users, meta: index_meta_data
  end

  # GET /v1/users/:id
  def show
    render json: @user
  end

  private

  # Finds the requested user
  def find_user
    @user = User.find(params[:id])
    authorize @user
  end

  # Returns the meta data for the index request
  def index_meta_data
    {
      q: params[:q],
      page: @users.current_page,
      per_page: @users.limit_value,
      total_pages: @users.total_pages
    }
  end
end
