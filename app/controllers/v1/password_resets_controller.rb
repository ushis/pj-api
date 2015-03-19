class V1::PasswordResetsController < V1::ApplicationController
  skip_before_action :authenticate,      only: [:create]
  skip_after_action  :verify_authorized, only: [:create]

  before_action :find_user, only: [:update]

  # POST /v1/password_reset
  def create
    @user = User.find_by_username_or_email!(username)
    UserMailer.password_reset(@user).deliver_later
    head :created
  end

  # PATCH /v1/password_reset
  def update
    if @user.update(password_params)
      head :no_content
    else
      render_error :unprocessable_entity, @user.errors
    end
  end

  private

  # Returns the username parameter
  def username
    params.require(:user).try(:fetch, :username, nil)
  end

  # Returns the permitted password parameters
  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Finds the requested user
  def find_user
    @user = current_user
    authorize @user
  end

  # Returns the current user identified by password reset token
  def current_user
    @current_user ||= User.find_by_password_reset_token(access_token)
  end
end
