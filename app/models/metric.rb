class Metric
  class << self

    def influx
      @influx ||= InfluxDB::Client.new(ENV.fetch('INFLUXDB_DB'), {
        host: ENV.fetch('INFLUXDB_HOST'),
        port: ENV.fetch('INFLUXDB_PORT', 8086),
        username: ENV.fetch('INFLUXDB_USER'),
        password: ENV.fetch('INFLUXDB_PASSWORD'),
        async: true
      })
    end
  end

  def initialize(event)
    @event = event
  end

  def tags
    @event.payload.slice(:controller, :action, :status)
  end

  def controller_runtime
    @event.duration
  end

  def view_runtime
    @event.payload.fetch(:view_runtime, 0.0).to_f
  end

  def db_runtime
    @event.payload.fetch(:db_runtime, 0.0).to_f
  end

  def save
    influx.write_point('rails.controller', {
      values: {value: controller_runtime},
      tags: tags
    })

    influx.write_point('rails.view', {
      values: {value: view_runtime},
      tags: tags
    })

    influx.write_point('rails.db', {
      values: {value: db_runtime},
      tags: tags
    })
  end

  private

  def influx
    self.class.influx
  end
end
