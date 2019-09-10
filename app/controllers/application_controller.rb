class ApplicationController < ActionController::API
  include ActionController::Serialization
  include Pundit

  rescue_from Pundit::NotAuthorizedError,         with: :forbidden
  rescue_from ActiveRecord::RecordNotFound,       with: :not_found
  rescue_from ActionController::ParameterMissing, with: :unprocessable_entity

  before_action :set_raven_context
  before_action :add_cors_headers
  before_action :authenticate

  after_action :verify_authorized,  except: [:options, :index]

  skip_before_action :authenticate, only: [:options]

  serialization_scope :current_user

  # Handles all OPTIONS requests
  def options
    head 204
  end

  private

  # Gives raven some context
  def set_raven_context
    Raven.user_context(id: current_user.try(:id))
    Raven.extra_context(params: params.to_unsafe_h)
  end

  # Adds CORS headers to the response
  def add_cors_headers
    headers['Access-Control-Max-Age'] = '1728000'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type'
  end

  # Renders an error
  def render_error(status, details=nil)
    error = status.to_s.titleize
    details = details.is_a?(String) ? {base: details} : details
    render json: {error: error, details: details}.compact, status: status
  end

  # Renders a 401 error
  def unauthorized
    headers['WWW-Authenticate'] = 'Bearer realm="API"'
    head :unauthorized
  end

  # Renders a 403 error
  def forbidden(error)
    render_error(:forbidden, error.message)
  end

  # Renders a 404 error
  def not_found(error)
    render_error(:not_found, error.message)
  end

  # Renders a 422 error
  def unprocessable_entity(error)
    render_error(:unprocessable_entity, error.message)
  end

  # Ensures that the request comes from an authenticated user
  def authenticate
    unauthorized if current_user.nil?
  end

  # Returns the current user or nil if this is an anonymous request
  def current_user
    @current_user ||= User.find_by_access_token(access_token)
  end

  # Returns the requests access token
  def access_token
    request.headers['Authorization'].to_s.split.last
  end

  # We should get rid of active model serializers.
  def namespace_for_serializer
    namespace = self.class.module_parent
    namespace == Object ? nil : namespace
  end
end
