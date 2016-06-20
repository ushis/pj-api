class RequestMetric < ApplicationMetric

  def controller_runtime
    event.duration
  end

  def view_runtime
    payload.fetch(:view_runtime, 0.0).to_f
  end

  def db_runtime
    payload.fetch(:db_runtime, 0.0).to_f
  end

  def tags
    payload.slice(:controller, :action, :method, :status)
  end

  def data
    {
      'rails.controller': controller_runtime,
      'rails.view': view_runtime,
      'rails.db': db_runtime
    }
  end
end
