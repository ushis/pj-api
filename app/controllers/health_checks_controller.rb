class HealthChecksController < ApplicationController
  skip_before_action :authenticate

  # GET /health
  def show
    @health_check = HealthCheck.new
    authorize @health_check
    render json: @health_check, serializer: HealthCheckSerializer, root: false
  end
end
