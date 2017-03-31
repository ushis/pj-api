class HealthCheckSerializer < ApplicationSerializer
  attributes :status, :components

  def status
    object.healthy? ? 'ok' : 'critical'
  end

  def components
    object.components.map { |component|
      [
        component.name,
        component.healthy? ? 'ok' : "critical: #{component.error}"
      ]
    }.to_h
  end
end
