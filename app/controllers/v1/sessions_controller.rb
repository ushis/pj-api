class V1::SessionsController < V1::ApplicationController
  skip_before_action :authenticate,      only: [:create]
  skip_after_action  :verify_authorized, only: [:create]

  # POST /v1/session
  def create
    @user = User.find_by_username_or_email(username)

    if @user.try(:authenticate, password)
      render json: @user, scope: @user, serializer: SessionSerializer, status: :created
    else
      unauthorized
    end
  end

  private

  # Returns the provided username
  def username
    params.require(:user).try(:fetch, :username, nil)
  end

  # Returns the provided password
  def password
    params.require(:user).try(:fetch, :password, nil)
  end
end
